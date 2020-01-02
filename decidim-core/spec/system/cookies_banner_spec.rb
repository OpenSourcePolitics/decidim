# frozen_string_literal: true

require "spec_helper"

describe "Cookies", type: :system do
  let(:organization) { create(:organization) }
  let(:last_user) { Decidim::User.last }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  it "user see the cookie banner" do
    expect(page).to have_content "I agree to all cookies"
  end

  it "user see more informations button" do
    expect(page).to have_content "More informations"
  end

  context "when user accept the cookie policy and he doesn't see it anymore'" do

    it "should not see it anymore" do
      click_button "I agree to all cookies"
      expect(page).to have_no_content "I agree to all cookies"

      visit decidim.root_path
      expect(page).to have_no_content "I agree to all cookies"
    end
  end

  context "when user clicks on more informations link" do

    before do
      click_button "More informations"
    end

    it "opens a new modal" do
      expect(page).to have_content "Let us know you agree to cookies"
      expect(page).to have_content "Activated"
    end

    it "is possible to activate / deactivate cookie" do
      input = find("input.switch-input", match: :first, visible: false)
      check_inspect_script = "$(`#deactivate_cc_" + input["data-cc"] + "`).is(':checked')"
      find("label.switch-paddle", match: :first).click
      expect(evaluate_script(check_inspect_script)).to eq(false)

      find("label.switch-paddle", match: :first).click
      expect(evaluate_script(check_inspect_script)).to eq(true)

    end
  end
end
