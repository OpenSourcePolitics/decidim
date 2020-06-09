# frozen_string_literal: true

require "spec_helper"

describe "Private Space Participatory", type: :system do
  let(:organization) { create(:organization) }

  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:main_user) { create(:user, :confirmed, organization: organization) }
  let!(:other_user) { create(:user, :confirmed, organization: organization) }

  let!(:participatory_space_private_main_user) { create :participatory_space_private_user, user: main_user, privatable_to: participatory_space_private }
  let!(:participatory_space_private_user) { create :participatory_space_private_user, user: other_user, privatable_to: participatory_space_private }

  let!(:participatory_space_private) { create :assembly, :published, organization: organization, private_space: true }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.root_path
  end

  context "when there is users" do
    before do
      click_link "Assemblies"
      click_link participatory_space_private.translated_title
      click_link "Private users"
    end

    it "displays users in private space" do
      within "#private_users" do
        expect(page).to have_content(main_user.name)
        expect(page).to have_content(other_user.name)
      end
    end
  end

  context "when a user is removed manually" do
    before do
      Decidim::User.find_by(email: main_user.email).destroy
      click_link "Assemblies"
      click_link participatory_space_private.translated_title
      click_link "Private users"
    end

    it "displays users in private space" do
      within "#private_users" do
        expect(page).not_to have_content(main_user.name)
        expect(page).to have_content(other_user.name)
      end
    end
  end
end
