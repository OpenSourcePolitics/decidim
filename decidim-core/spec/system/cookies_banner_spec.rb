# frozen_string_literal: true

require "spec_helper"

describe "Cookies", type: :system do
  let(:organization) { create(:organization) }

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
    it "does not see it anymore" do
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
      expect(page).to have_content "Cookies statement"
    end

    context "when matomo tracking is enabled in initializers" do
      it "shows the matomo opt-out" do
        expect(page).to have_css("iframe")
      end
    end

    context "when matomo tracking is disabled in initializers" do
      before do
        Decidim.enable_matomo_tracking = false
      end

      it "doesn't show the matomo opt-out" do
        expect(page).not_to have_css("iframe")
      end
    end
  end
end
