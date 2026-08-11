# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe AuthorConfirmationProposalEvent do
      let(:resource) { create(:proposal) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
      let(:event_name) { "decidim.events.proposals.author_confirmation_proposal_event" }

      include_context "when a simple event"

      it_behaves_like "a simple event"

      describe "resource_title" do
        it "returns the proposal title" do
          expect(subject.resource_title).to eq(decidim_sanitize_translated(resource.title))
        end
      end
    end
  end
end
