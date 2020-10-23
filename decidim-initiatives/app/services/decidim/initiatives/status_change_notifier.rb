# frozen_string_literal: true

module Decidim
  module Initiatives
    # Service that reports changes in initiative status
    class StatusChangeNotifier
      attr_reader :initiative

      def initialize(args = {})
        @initiative = args.fetch(:initiative)
      end

      # PUBLIC
      # Notifies when an initiative has changed its status.
      #
      # * created: Notifies the author that his initiative has been created.
      #
      # * validating: Administrators will be notified about the initiative that
      #   requests technical validation.
      #
      # * published, discarded: Initiative authors will be notified about the
      #   result of the technical validation process.
      #
      # * rejected, accepted: Initiative's followers and authors will be
      #   notified about the result of the initiative.
      def notify
        notify_initiative_creation if created?
        notify_validating_initiative if validating?
        notify_validating_result if validating_result?
        notify_support_result if support_result?
        notify_manual_change if manual_changes?
      end

      private

      def created?
        initiative.created?
      end

      def validating?
        initiative.validating?
      end

      def validating_result?
        initiative.published? || initiative.discarded?
      end

      def support_result?
        initiative.rejected? || initiative.accepted?
      end

      def manual_changes?
        initiative.classified? || initiative.examinated? || initiative.debatted?
      end

      def notify_initiative_creation
        notify_creation
      end

      def notify_validating_initiative
        notify_admins
      end

      def notify_validating_result
        notify_committee_members
        notify_author
      end

      def notify_support_result
        notify_followers
        notify_committee_members
        notify_author
      end

      def notify_manual_change
        notify_followers
        notify_committee_members
        notify_author
      end

      def notify_committee_members
        initiative.committee_members.approved.each do |committee_member|
          next unless initiative.author != committee_member.user

          Decidim::Initiatives::InitiativesMailer
            .notify_state_change(initiative, committee_member.user)
            .deliver_later
        end
      end

      def notify_followers
        initiative.followers.each do |follower|
          next unless initiative.author != follower

          Decidim::Initiatives::InitiativesMailer
            .notify_state_change(initiative, follower)
            .deliver_later
        end
      end

      def notify_author
        Decidim::Initiatives::InitiativesMailer
          .notify_state_change(initiative, initiative.author)
          .deliver_later
      end

      def notify_admins
        initiative.organization.admins.each do |user|
          next unless user.email_on_notification?

          Decidim::Initiatives::InitiativesMailer
            .notify_validating_request(initiative, user)
            .deliver_later
        end
      end

      def notify_creation
        Decidim::Initiatives::InitiativesMailer
          .notify_creation(initiative)
          .deliver_later
      end
    end
  end
end
