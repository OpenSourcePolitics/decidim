# frozen_string_literal: true

require "spec_helper"
require "decidim/initiatives/end_of_mandate_archivist"

describe Decidim::Initiatives::EndOfMandateArchivist do
  let(:organization) { create(:organization) }
  let(:category_name) { "Category 1" }
  let(:archivist) { described_class.archive(category_name, organization.id, false) }

  it "creates a category" do
    expect { archivist }.to change(Decidim::InitiativesArchiveCategory, :count)
  end

  context "when category already exists" do
    let!(:archive_category) { create(:archive_category, name: category_name, organization: organization) }

    it "reuses category" do
      expect { archivist }.not_to change(Decidim::InitiativesArchiveCategory, :count)
    end
  end

  context "when category already exists in another organization" do
    let(:archive_category) { create(:archive_category, name: category_name, organization: create(:organization)) }

    it "creates a category" do
      expect { archivist }.to change(Decidim::InitiativesArchiveCategory, :count)
    end
  end

  describe "#call" do
    context "when initiatives are not archived" do
      let!(:initiatives) { create_list(:initiative, 5, organization: organization) }

      it "archives initiatives" do
        archivist

        expect(Decidim::Initiative.archived).to match_array(initiatives)
      end

      context "when initiatives are archived" do
        let!(:initiatives) { create_list(:initiative, 5, :archived, organization: organization) }

        it "doesn't change initiatives" do
          archivist

          expect(Decidim::Initiative.not_archived).to be_empty
        end
      end
    end
  end
end
