# frozen-string_literal: true

module Decidim
  module Initiatives
    class ApproveMembershipRequestEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_subject
        I18n.t(
          "decidim.initiatives.events.approve_membership_request.email_subject",
          author_name: author_name
        )
      end

      def email_intro
        I18n.t(
          "decidim.initiatives.events.approve_membership_request.email_intro",
          resource_title: resource_title,
          resource_url: resource_url,
          author_profile_url: author_profile_url,
          author_name: author_name
        )
      end

      def email_outro
        I18n.t(
          "decidim.initiatives.events.approve_membership_request.email_outro",
          resource_title: resource_title,
          resource_url: resource_url
        )
      end

      def notification_title
        I18n.t(
          "decidim.initiatives.events.approve_membership_request.notification_title",
          resource_title: resource_title,
          resource_url: resource_url,
          author_profile_url: author_profile_url,
          author_name: author_name
        ).html_safe
      end

      private

      def author_name
        author.name
      end

      def author_profile_url
        author.profile_url
      end

      def author
        @author ||= Decidim::UserPresenter.new(
          Decidim::User.find(@extra["author"]["id"])
        )
      end
    end
  end
end
