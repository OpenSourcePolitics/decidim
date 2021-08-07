# frozen_string_literal: true

module Decidim
  class PseudomizeResourceAuthorsJob < ApplicationJob
    queue_as :default

    def perform(resource, cache_entry)
      if resource.respond_to?(:authors)
        old_authors = resource.authors

        notify_users(old_authors)

        authors = old_authors.map { |author| create_or_find_author(author, resource.organization) }

        resource.transaction do
          resource.coauthorships.delete_all
          resource.reload
          authors.each { |author| resource.add_coauthor(author) }
          resource.save!
        end
      else
        old_author = resource.author

        notify_user(old_author)

        resource.update!(author: create_or_find_author(old_author, resource.organization))
      end

      increment_resources_counter(cache_entry)
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

    def notify_users(users)
      users.each { |user| notify_user(user) }
    end

    def notify_user(user)
      Decidim::Admin::PseudomizeMailer.notify_user(user)
    end

    def increment_resources_counter(cache_entry)
      entry = Rails.cache.fetch(cache_entry)
      new_entry = entry.merge(current: entry[:current] + 1)
      Rails.cache.write(cache_entry, new_entry)
    end
  end
end
