# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when a user unreports a resource.
    class HideUpstreamResource < Rectify::Command
      # Public: Initializes the command.
      #
      # reportable - A Decidim::Reportable
      # current_user - the user performing the action
      def initialize(upstream_reportable, current_user)
        @upstream_reportable = upstream_reportable
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource is not reported
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @upstream_reportable

        hide!
        send_notification_to_author

        broadcast(:ok, @reportable)
      end

      private

      def hide!
        Decidim.traceability.perform_action!(
          "hide",
          @upstream_reportable.upstream_moderation,
          @current_user,
          extra: {
            upstream_reportable_type: @upstream_reportable.class.name
          }
        ) do
          @upstream_reportable.upstream_moderation.update!(
            pending: false
          )
        end
      end

      def send_notification_to_author
        Decidim::EventsManager.publish(
          event: "decidim.events.admin.upstream_hidden",
          event_class: Decidim::UpstreamHiddenEvent,
          resource: @upstream_reportable,
          affected_users: authors
        )
      end

      def authors
        if @upstream_reportable.class.name == "Decidim::Comments::Comment"
          [@upstream_reportable.author]
        elsif @upstream_reportable.class.name == "Decidim::Proposals::Proposal"
          @upstream_reportable.authors
        elsif @upstream_reportable.class.name == "Decidim::Questions::Question"
          @upstream_reportable.authors
        end
      end
    end
  end
end
