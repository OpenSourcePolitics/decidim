# frozen_string_literal: true

require "spec_helper"

def fill_registration_form
  fill_in :user_name, with: "Nikola Tesla"
  fill_in :user_nickname, with: "the-greatest-genius-in-history"
  fill_in :user_email, with: "nikola.tesla@example.org"
  fill_in :user_password, with: "sekritpass123"
  fill_in :user_password_confirmation, with: "sekritpass123"
end

def fill_registration_metadata
  select translated(scopes.first.name), from: :user_residential_area
  select translated(scopes.first.name), from: :user_work_area
  select "Other", from: :user_gender
  select "September", from: :user_month
  select "1992", from: :user_year
  check :underage_registration
  fill_in :user_statutory_representative_email, with: "milutin.tesla@example.org"
  check :user_additional_tos
end

describe "Registration", type: :system do
  let!(:scopes) { create_list(:scope, 5, organization: organization) }
  let(:organization) { create(:organization) }
  let!(:terms_and_conditions_page) { Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization: organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.new_user_registration_path
  end

  context "when signing up" do
    describe "on first sight" do
      it "shows fields empty" do
        expect(page).to have_content("Sign up to participate")
        expect(page).to have_field("user_name", with: "")
        expect(page).to have_field("user_nickname", with: "")
        expect(page).to have_field("user_email", with: "")
        expect(page).to have_field("user_password", with: "")
        expect(page).to have_field("user_password_confirmation", with: "")
        expect(page).to have_field("user_newsletter", checked: false)
        expect(page).to have_select("user[residential_area]", selected: "Please select")
        expect(page).to have_select("user[work_area]", selected: "Please select")
        expect(page).to have_select("user[gender]", selected: "Male")
        expect(page).to have_select("user[month]", selected: "January")
        expect(page).to have_select("user[year]", selected: Time.current.year.to_s)
        expect(page).to have_unchecked_field("Underage")
      end
    end
  end

  context "when newsletter checkbox is unchecked" do
    it "opens modal on submit" do
      within "form.new_user" do
        find("*[type=submit]").click
      end
      expect(page).to have_css("#sign-up-newsletter-modal", visible: true)
      expect(page).to have_current_path decidim.new_user_registration_path
    end

    it "checks when clicking the checking button" do
      within "form.new_user" do
        find("*[type=submit]").click
      end
      click_button "Check and continue"
      expect(page).to have_current_path decidim.new_user_registration_path
      expect(page).to have_css("#sign-up-newsletter-modal", visible: false)
      expect(page).to have_field("user_newsletter", checked: true)
    end

    it "submit after modal has been opened and selected an option" do
      within "form.new_user" do
        find("*[type=submit]").click
      end
      click_button "Keep uncheck"
      expect(page).to have_css("#sign-up-newsletter-modal", visible: false)
      fill_registration_form
      within "form.new_user" do
        find("*[type=submit]").click
      end
      expect(page).to have_current_path decidim.user_registration_path
      expect(page).to have_field("user_newsletter", checked: false)
    end
  end

  context "when newsletter checkbox is checked but submit fails" do
    before do
      fill_registration_form
      page.check("user_newsletter")
    end

    it "keeps the user newsletter checkbox true value" do
      within "form.new_user" do
        find("*[type=submit]").click
      end
      expect(page).to have_current_path decidim.user_registration_path
      expect(page).to have_field("user_newsletter", checked: true)
    end
  end

  context "when registering with additional fields" do
    before do
      fill_registration_form
      fill_registration_metadata
      page.check("user_newsletter")
      page.check("user_tos_agreement")
    end

    it "allows user to register" do
      within "form.new_user" do
        find("*[type=submit]").click
      end

      expect(page).to have_content("Welcome! You have signed up successfully.")
    end
  end
end
