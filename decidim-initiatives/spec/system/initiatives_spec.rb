# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "Initiatives", type: :system do
  let(:organization) { create(:organization) }
  let(:base_initiative) do
    create(:initiative, organization: organization)
  end

  before do
    switch_to_host(organization.host)
  end

  context "when there are some published initiatives" do
    let!(:initiative) { base_initiative }
    let!(:unpublished_initiative) do
      create(:initiative, :created, organization: organization)
    end

    before do
      visit decidim_initiatives.initiatives_path
    end

    it_behaves_like "shows contextual help" do
      let(:index_path) { decidim_initiatives.initiatives_path }
      let(:manifest_name) { :initiatives }
    end

    it_behaves_like "editable content for admins"

    context "when accessing from the homepage" do
      it "the menu link is shown" do
        visit decidim.root_path

        within ".main-nav" do
          expect(page).to have_content("Initiatives")
          click_link "Initiatives"
        end

        expect(page).to have_current_path(decidim_initiatives.initiatives_path)
      end
    end

    it "lists all the initiatives" do
      within "#initiatives-count" do
        expect(page).to have_content("1")
      end

      within "#initiatives" do
        expect(page).to have_content(translated(initiative.title, locale: :en))
        expect(page).to have_content(initiative.author_name, count: 1)
        expect(page).not_to have_content(translated(unpublished_initiative.title, locale: :en))
      end
    end

    context "for votable manual state initiative" do
      let(:base_initiative) { create(:initiative, :debatted, organization: organization) }

      it "displays a signature gauge" do
        within "#initiatives" do
          expect(page).to have_content(translated(initiative.title, locale: :en))
          expect(page).to have_css("#initiative-#{initiative.id}-signatures-count")
        end
      end
    end

    it "links to the individual initiative page" do
      click_link(translated(initiative.title, locale: :en))
      expect(page).to have_current_path(decidim_initiatives.initiative_path(initiative))
    end

    it "displays the filter initiative type filter" do
      within ".new_filter[action='/initiatives']" do
        expect(page).to have_css("#filter_type")
      end
    end

    context "when validating state initiative" do
      let(:validating_initiative) { create(:initiative, :validating, organization: organization) }

      it "does not display the validating initiative" do
        within "#initiatives" do
          expect(page).to have_content(translated(initiative.title, locale: :en))
          expect(page).to have_content(initiative.author_name, count: 1)
          expect(page).not_to have_content(translated(validating_initiative.title, locale: :en))
        end
      end
    end

    context "when there is a unique initiative type" do
      let!(:unpublished_initiative) { nil }

      it "doesn't display the initiative type filter" do
        within ".new_filter[action='/initiatives']" do
          expect(page).not_to have_css("#filter_type")
        end
      end
    end

    context "when in a manual state" do
      let(:base_initiative) { create(:initiative, :debatted, organization: organization) }

      it "displays the correct badge status" do
        within "#initiative_#{base_initiative.id}" do
          expect(page).to have_css(".success.card__text--status")
        end
      end
    end

    context "when linked to an area" do
      let!(:area) { create(:area, organization: organization) }
      let(:base_initiative) { create(:initiative, :published, :with_area, area: area, organization: organization) }

      it "doesn't display area-header" do
        within "#initiative_#{base_initiative.id}" do
          expect(page).not_to have_css(".area-header")
        end
      end

      context "when area has color" do
        let!(:area) { create(:area, :with_color, organization: organization) }

        it "displays area header with background color" do
          within "#initiative_#{base_initiative.id}" do
            expect(page).to have_css(".area-header")

            within ".area-header" do
              expect(page).to have_content(translated(area.name, locale: :en))
            end
          end
        end

        context "when area has logo" do
          let!(:area) { create(:area, :with_color, :with_logo, organization: organization) }

          it "displays logo inside a tooltip" do
            within "#initiative_#{base_initiative.id}" do
              within ".area-header" do
                within "span[data-tooltip=\"true\"]" do
                  expect(page).to have_selector("img")
                end
              end
            end
          end
        end
      end
    end
  end

  context "when sorting initiatives" do
    before do
      visit decidim_initiatives.initiatives_path
    end

    it "displays the sorting list" do
      expect(page).to have_content("Sort initiatives by")

      within "#initiatives .collection-sort-controls" do
        expect(page).to have_css("a", text: "Random")
        expect(page).to have_css("a", text: "Most recent", visible: false)
        expect(page).to have_css("a", text: "Most signed", visible: false)
        expect(page).to have_css("a", text: "Most recently published", visible: false)
        expect(page).to have_css("a", text: "Answer date", visible: false)
      end
    end
  end
end
