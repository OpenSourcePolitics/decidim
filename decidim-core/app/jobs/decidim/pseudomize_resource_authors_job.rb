# frozen_string_literal: true

module Decidim
  class PseudomizeResourceAuthorsJob < ApplicationJob
    queue_as :default

    def perform(resource)
      if resource.respond_to?(:authors)
        authors = resource.authors.map { |author| create_or_find_author(author, resource.organization) }

        resource.transaction do
          resource.coauthorships.delete_all
          resource.reload
          authors.each { |author| resource.add_coauthor(author) }
          resource.save!
        end
      else
        resource.update!(author: create_or_find_author(resource.author, resource.organization))
      end
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
  end
end
