# frozen_string_literal: true

module Decidim
  class PseudomizeResourcesGeneratorJob < ApplicationJob
    queue_as :default

    def perform(user, component, resources)
      @component = component

      notify_users(resources)

      resources.each do |resource|
        if resource.respond_to?(:authors)
          authors = resource.authors.map { |author| creates_and_transfer(author, resource.organization) }

          resource.transaction do
            resource.coauthorships.delete_all
            resource.reload
            authors.each { |author| resource.add_coauthor(author) }
            resource.save!
          end
        else
          user = resource.author
          resource.author = create_or_find_author(resource.author, resource.organization)
          transfer_action_log_ownership(user, resource.author)
          resource.save(validate: false)
        end

        status_manager.increment_resources_counter!
      end

      Decidim::EndOfPseudomizeResourcesTaskJob.perform_later(user, component)
    end

    private

    def create_or_find_author(user, organization)
      return user if user.is_a?(Decidim::Organization) || user.shadow?

      Decidim::User.find_by(email: pseudomizer(user).email, organization: organization) || create_author(user, organization)
    end

    def create_author(user, organization)
      password = SecureRandom.hex(64)

      user = Decidim::User.new(
        shadow: true,
        email: pseudomizer(user).email,
        name: pseudomizer(user).name,
        nickname: Decidim::User.nicknamize(pseudomizer(user).nickname),
        password: password,
        password_confirmation: password,
        organization: organization,
        tos_agreement: true,
        newsletter_notifications_at: Time.current,
        email_on_notification: false,
        accepted_tos_version: organization.tos_version
      )

      user.skip_confirmation!
      user.save

      user
    end

    def pseudomizer(user)
      Decidim::UserPseudomizer.pseudomize(user)
    end

    def notify_users(resources)
      users = resources.flat_map { |resource| resource.respond_to?(:authors) ? resource.authors : resource.author }

      users.uniq.each do |user|
        notify_user(user)
      end
    end

    def notify_user(user)
      Decidim::Admin::PseudomizeMailer.notify_user(user).deliver_later
    end

    def status_manager
      @status_manager ||= Decidim::PseudomizeResourcesStatusManager.new(@component)
    end

    def transfer_action_log_ownership(user, pseudomized_user)
      return if user.is_a?(Decidim::Organization) || user.shadow? || pseudomized_user.blank?

      action_logs = Decidim::ActionLog.where(decidim_user_id: user.id, decidim_component_id: @component.id, decidim_organization_id: user.organization)
      return if action_logs.blank?

      action_logs.each { |action| action.update_column(:decidim_user_id, pseudomized_user.id)}
    end

    def creates_and_transfer(author, organization)
      user = create_or_find_author(author, organization)
      transfer_action_log_ownership(author, user)

      user
    end
  end
end
