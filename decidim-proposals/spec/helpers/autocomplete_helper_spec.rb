# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe AutocompleteHelper do
      let(:organization) { create(:organization) }
      let(:proposal_component) { create(:proposal_component, organization: organization) }
      let(:default_datalist_id) { "here_suggestions" }

      before do
        allow(helper).to receive(:current_component).and_return(proposal_component)
      end

      it "returns datalist with script" do
        expected = helper.here_autocomplete default_datalist_id do
          javascript_include_tag "decidim/proposals/autocomplete"
        end

        expect(expected).to eq("<datalist data-here-api=\"#{Decidim.geocoder[:here_api_key]}\" id=\"#{default_datalist_id}\"></datalist><script src=\"/javascripts/decidim/proposals/autocomplete.js\"></script>")
      end

      context "when geocoding is disabled" do
        before do
          Decidim.geocoder = nil
        end

        it "returns nil" do
          expected = helper.here_autocomplete do
            javascript_include_tag "decidim/proposals/autocomplete"
          end

          expect(expected).to be_nil
        end
      end
    end
  end
end
