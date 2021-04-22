# frozen_string_literal: true

require "spec_helper"
require "decidim/initiatives/end_of_mandate_archivist"

describe Decidim::Initiatives::EndOfMandateArchivist do
  let(:organization) { create(:organization) }
  let(:category_name) { "Category 1" }
  let(:archivist) { described_class.archive(category_name, organization.id, false) }

  describe "#archive_initiatives" do
    it "creates a category" do
      expect { archivist.call }.to change(Decidim::InitiativesArchiveCategory, :count)
    end

    context "when category already exists" do
      let!(:archive_category) { create(:archive_category, name: category_name, organization: organization) }

      it "reuses category" do
        expect { archivist.call }.not_to change(Decidim::InitiativesArchiveCategory, :count)
      end
    end

    context "when category already exists in another organization" do
      let(:archive_category) { create(:archive_category, name: category_name, organization: create(:organization)) }

      it "creates a category" do
        expect { archivist.call }.to change(Decidim::InitiativesArchiveCategory, :count)
      end
    end

    context "when initiatives are not archived" do
      let!(:initiatives) { create_list(:initiative, 5, organization: organization) }

      it "archives initiatives" do
        expect { archivist.call }.to change(Decidim::Initiative.archived, :count)
      end

      context "when initiatives are archived" do
        let!(:initiatives) { create_list(:initiative, 5, :archived, organization: organization) }

        it "doesn't change initiatives" do
          expect { archivist.call }.not_to change(Decidim::Initiative.not_archived, :count)
        end
      end
    end
  end

  describe "#delete_authors" do
    let!(:first_user) { create(:user, organization: organization) }
    let!(:first_initiative) { create(:initiative, author: first_user, organization: organization) }

    let!(:second_user) { create(:user, organization: organization) }
    let!(:second_initiative) { create(:initiative, author: second_user, organization: organization) }

    let!(:third_user) { create(:user, organization: organization) }
    let!(:committee_member) { create(:initiatives_committee_member, initiative: first_initiative, user: third_user) }

    let!(:fourth_user) { create(:user, organization: organization) }

    it "deletes authors and committee_member" do
      archivist.call

      expect(first_user.reload.email).to eq("")
      expect(second_user.reload.email).to eq("")
      expect(third_user.reload.email).to eq("")
      expect(fourth_user.reload.email).not_to eq("")
    end
  end

  describe "#delete_authorizations" do
    let!(:first_user) { create(:user, organization: organization) }
    let!(:first_authorization) { create(:authorization, name: "dummy_authorization_handler", user: first_user, metadata: { nickname: first_user.nickname }, granted_at: 2.seconds.ago) }
    let!(:first_initiative) { create(:initiative, author: first_user, organization: organization) }

    let!(:second_user) { create(:user, organization: organization) }
    let!(:second_authorization) { create(:authorization, name: "dummy_authorization_handler", user: second_user, metadata: { nickname: second_user.nickname }, granted_at: 2.seconds.ago) }
    let!(:second_initiative) { create(:initiative, author: second_user, organization: organization) }

    let!(:third_user) { create(:user, organization: organization) }
    let!(:third_authorization) { create(:authorization, name: "dummy_authorization_handler", user: third_user, metadata: { nickname: third_user.nickname }, granted_at: 2.seconds.ago) }
    let!(:committee_member) { create(:initiatives_committee_member, initiative: first_initiative, user: third_user) }

    let!(:fourth_user) { create(:user, organization: organization) }
    let!(:fourth_authorization) { create(:authorization, name: "dummy_authorization_handler", user: fourth_user, metadata: { nickname: fourth_user.nickname }, granted_at: 2.seconds.ago) }

    it "deletes authors and committee_members metadata authorization" do
      archivist.call

      expect(first_authorization.reload.encrypted_metadata).to eq(nil)
      expect(second_authorization.reload.encrypted_metadata).to eq(nil)
      expect(third_authorization.reload.encrypted_metadata).to eq(nil)
      expect(fourth_authorization.reload.encrypted_metadata).not_to eq(nil)
    end
  end
end
