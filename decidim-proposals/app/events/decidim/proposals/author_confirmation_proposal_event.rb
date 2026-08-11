# frozen_string_literal: true

module Decidim
  module Proposals
    class AuthorConfirmationProposalEvent < Decidim::Events::SimpleEvent
      def self.model_name
        ActiveModel::Name.new(self, nil, I18n.t("decidim.events.proposals.author_confirmation_proposal_event.email_subject"))
      end

      def resource_title
        decidim_sanitize_translated(resource.title)
      end
    end
  end
end
