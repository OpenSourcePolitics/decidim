# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the components needed when you want a model to be reportable
  module UpstreamReportable
    extend ActiveSupport::Concern

    included do
      has_one :upstream_moderation,
              as: :upstream_reportable,
              foreign_key: "decidim_upstream_reportable_id",
              foreign_type: "decidim_upstream_reportable_type",
              class_name: "Decidim::UpstreamModeration"

      scope :upstream_not_hidden, -> { left_outer_joins(:upstream_moderation).where(Decidim::UpstreamModeration.arel_table[:hidden_at].eq nil) }
      scope :upstream_hidden, -> { left_outer_joins(:upstream_moderation).where.not(Decidim::UpstreamModeration.arel_table[:hidden_at].eq nil) }

      def add_to_upstream_moderation
        return unless upstream_moderation_activated?
        return if author_has_role?

        Decidim::UpstreamModeration.find_or_create_by!(
          upstream_reportable: self,
          participatory_space: participatory_space
        ).update!(hidden_at: Time.zone.now)

        send_upstream_notifications
      end

      def upstream_moderation_activated?
        try(:component).try(:settings).try(:upstream_moderation) || false
      end

      def upstream_not_hidden_for?(user)
        created_by?(user)
      end

      def comment_threads
        super.reject(&:upstream_hidden?)
      end

      # Public: Checks if the reportable is hidden or not.
      #
      # Returns Boolean.
      def upstream_hidden?
        upstream_moderation&.hidden_at&.present?
      end

      # Public: Checks if the reportable is awaiting moderation
      #
      # Returns Boolean.
      def upstream_pending?
        upstream_moderation&.try(:pending)
      end

      # Public: The reported content url
      #
      # Returns String
      def reported_content_url
        raise NotImplementedError
      end

      def send_upstream_notifications
        Decidim::EventsManager.publish(
          event: "decidim.events.admin.upstream_pending",
          event_class: Decidim::UpstreamPendingEvent,
          resource: event_resource,
          affected_users: event_affected_users,
          followers: participatory_space_moderators
        )
      end

      def participatory_space_moderators
        @participatory_space_moderators ||= participatory_space.moderators
      end

      private

      def event_resource
        return root_commentable if is_a? Decidim::Comments::Comment

        self
      end

      def event_affected_users
        return [author] if is_a? Decidim::Comments::Comment

        authors
      end

      def author_has_role?
        author = if is_a? Decidim::Comments::Comment
                   self.author
                 else
                   authors.first
                 end
        participatory_space_moderators.include? author
      end

      def participatory_space
        @participatory_space ||= component.participatory_space
      end
    end
  end
end
