# frozen_string_literal: true

require "spec_helper"

describe "Initiative", type: :system do
  let(:organization) { create(:organization) }
  let(:base_initiative) do
    create(:initiative, organization: organization)
  end

  before do
    switch_to_host(organization.host)
  end

  context "when the initiative does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_initiatives.initiative_path(99_999_999) }
    end
  end

  describe "initiative page" do
    let!(:initiative) { base_initiative }
    let(:attached_to) { initiative }

    before do
      visit decidim_initiatives.initiative_path(initiative)
    end

    it_behaves_like "editable content for admins"

    it "shows the details of the given initiative" do
      within "main" do
        expect(page).to have_content(translated(initiative.title, locale: :en))
        expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
        expect(page).to have_content(translated(initiative.type.title, locale: :en))
        expect(page).to have_content(initiative.author_name)
        expect(page).to have_content(initiative.hashtag)
        expect(page).to have_content(initiative.reference)
      end
    end

    it "shows the author name once in the authors list" do
      within ".initiative-authors" do
        expect(page).to have_content(initiative.author_name, count: 1)
      end
    end

    it "displays date" do
      within ".process-header__phase" do
        expect(page).not_to have_content(I18n.l(base_initiative.signature_start_date, format: :decidim_short))
        expect(page).to have_content(I18n.l(base_initiative.signature_end_date, format: :decidim_short))
      end
    end

    context "when in a manual state" do
      let(:base_initiative) { create(:initiative, :debatted, :with_answer, organization: organization) }

      it "displays the initiative status with the appropriate color" do
        expect(page).to have_css(".initiative-status.success")
        expect(page).to have_css(".initiative-answer.success")
      end

      it "displays date" do
        expect(page).to have_content(I18n.l(base_initiative.answer_date.to_date, format: :decidim_short))
      end
    end

    context "when archived" do
      let(:archive_category) { create(:archive_category, organization: organization) }
      let(:base_initiative) do
        create(
          :initiative,
          :archived,
          :debatted,
          :with_answer,
          decidim_initiatives_archive_categories_id: archive_category.id,
          organization: organization
        )
      end

      it "displays archive name" do
        within ".tags--initiative" do
          expect(page).to have_content(archive_category.name)
        end
      end

      it "displays archive logo" do
        expect(page).to have_css(".archive-header")

        within ".archive-header" do
          expect(page).to have_css("img")
        end
      end

      it "adds archived css class" do
        expect(page).to have_css(".initiative-status.archived")
        expect(page).to have_css(".initiative-answer.archived")
      end

      it "grays the gauge" do
        expect(page).to have_css(".vote-cabin-progress-bar__archived")
      end
    end

    context "when committee members count is inferior than 3" do
      before do
        Decidim::InitiativesCommitteeMember.last.destroy!
        Decidim::InitiativesCommitteeMember.last.destroy!
        visit decidim_initiatives.initiative_path(initiative)
      end

      it "doesn't display 'see more' nor 'see less' link" do
        within ".author-data__main" do
          expect(page).not_to have_content("See less")
          expect(page).not_to have_content("See more")
        end
      end
    end

    context "when there is multiple authors" do
      let!(:accepted_members) { create_list(:initiatives_committee_member, 5, initiative: base_initiative) }

      before do
        visit decidim_initiatives.initiative_path(initiative)
      end

      context "and authors number is over 3" do
        it "displays 'see more' link" do
          within ".author-data__main" do
            expect(page).to have_content("and 6 more people (See more)")
          end
        end

        context "when clicking on 'see more' link" do
          it "displays 'see less' link" do
            within ".author-data__main" do
              expect(page).not_to have_content("See less")
              expect(page).to have_content("and 6 more people (See more)")
              click_button "See more"
              expect(page).not_to have_content("See more")
              expect(page).to have_content("See less")
            end
          end
        end
      end
    end

    it_behaves_like "has attachments"
  end
end
