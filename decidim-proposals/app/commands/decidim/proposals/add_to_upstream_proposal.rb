# frozen_string_literal: true

module Decidim
  module Proposals
    class AddToUpstreamProposal < Rectify::Command
      # Public: Initializes the command.
      #
      # proposal     - The proposal to publish.
      # current_user - The current user.
      def initialize(proposal, current_user)
        @proposal = proposal
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid and the proposal is published.
      # - :invalid if the proposal's author is not the current user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @proposal.authored_by?(@current_user)

        transaction do
          @proposal.add_to_upstream_moderation
          @proposal.update(
            title: reset(:title),
            body: reset(:body),
            published_at: Time.current
          )
        end

        broadcast(:ok, @proposal)
      end

      private

      # Reset the attribute to an empty string and return the old value
      def reset(attribute)
        attribute_value = @proposal[attribute]
        PaperTrail.request(enabled: false) do
          # rubocop:disable Rails/SkipsModelValidations
          @proposal.update_attribute attribute, ""
          # rubocop:enable Rails/SkipsModelValidations
        end
        attribute_value
      end
    end
  end
end
