# frozen_string_literal: true

require "spec_helper"

describe "Initiative widget", type: :system do
  let(:organization) { create(:organization) }
  let(:initiative) { create(:initiative, organization: organization) }
  let(:widget_path) { decidim_initiatives.initiative_initiative_widget_path(initiative.slug) }

  before do
    switch_to_host(organization.host)
    visit widget_path
  end

  context "when the initiative is not published, accepted or rejected" do
    it "doesn't displays the iframe" do
      expect(page).not_to have_content(initiative.title)
    end
  end

  context "when created" do
    let(:initiative) { create(:initiative, :created, organization: organization) }

    it "doesn't displays the iframe" do
      expect(page).not_to have_content(initiative.title)
    end
  end

  context "when validating" do
    let(:initiative) { create(:initiative, :validating, organization: organization) }

    it "doesn't displays the iframe" do
      expect(page).not_to have_content(initiative.title)
    end
  end

  context "when discarded" do
    let(:initiative) { create(:initiative, :discarded, organization: organization) }

    it "doesn't displays the iframe" do
      expect(page).not_to have_content(initiative.title)
    end
  end

  context "when published" do
    let(:initiative) { create(:initiative, :published, organization: organization) }

    it "displays the iframe" do
      expect(page).to have_content(initiative.title)
    end
  end

  context "when accepted" do
    let(:initiative) { create(:initiative, :accepted, organization: organization) }

    it "displays the iframe" do
      expect(page).to have_content(initiative.title)
    end
  end

  context "when rejected" do
    let(:initiative) { create(:initiative, :rejected, organization: organization) }

    it "displays the iframe" do
      expect(page).to have_content(initiative.title)
    end
  end
end
