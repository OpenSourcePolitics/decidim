# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe SimilarInitiatives do
      subject { described_class.for(organization, form) }

      let!(:user) { create(:user, :confirmed, organization: organization) }
      let!(:organization) { create(:organization) }
      let!(:initiatives) { create_list(:initiative, 3, title: title, description: description, organization: organization, author: user) }
      let(:title) do
        { "en" => "title" }
      end
      let(:description) do
        { "en" => "description" }
      end
      let(:form) { Decidim::Initiatives::InitiativeForm.from_params(title: translated(title), description: translated(description)) }

      it "is included in the comparator" do
        expect(subject).to match_array(initiatives)
      end
    end
  end
end
