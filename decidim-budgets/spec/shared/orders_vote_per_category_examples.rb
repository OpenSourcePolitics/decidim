# frozen_string_literal: true

shared_examples "orders vote per category" do
  let!(:category) { create(:category, participatory_space: component.participatory_space) }
  let!(:other_category) { create(:category, participatory_space: component.participatory_space) }
  let(:projects_per_category_treshold) do
    {
      category.id.to_s => "1",
      other_category.id.to_s => "1"
    }
  end

  before do
    settings = component.settings.to_h.merge(
      vote_threshold_percent: 50,
      total_projects: 2,
      vote_per_category: true,
      projects_per_category_treshold: projects_per_category_treshold
    )

    component.update(settings: settings)
  end

  context "when the user is logged in" do
    before { login_as user, scope: :user }

    context "when voting by category" do
      let!(:projects) { create_list(:project, 2, component: component, budget: 50_000_000, category: category) }

      it "displays the voting rules" do
        visit_component

        within ".budget-summary" do
          within "#order-voting-rules" do
            expect(page).to have_content("1 project for #{category.translated_name}")
            expect(page).to have_content("1 project for #{other_category.translated_name}")
          end
        end
      end

      context "and has not a pending order" do
        it "adds a project to the current order" do
          visit_component

          within ".budget-summary" do
            within "#order-progress" do
              expect(page).to have_content("0%")
              expect(page).to have_button("Vote", disabled: true)
            end

            within "#order-selected-projects" do
              expect(page).to have_content("0 projects selected out of 1 for #{category.translated_name}")
              expect(page).to have_content("0 projects selected out of 1 for #{other_category.translated_name}")
              expect(page).to have_button("Vote", disabled: true)
            end
          end

          within "#projects" do
            within "#project-#{project.id}-item" do
              find("*[type=submit]").click
            end

            expect(page).to have_selector ".budget-list__data--added", count: 1
          end

          within ".budget-summary" do
            within "#order-progress" do
              expect(page).to have_content("50%")
              expect(page).to have_button("Vote", disabled: true)
            end

            within "#order-selected-projects" do
              expect(page).to have_content(translated_attribute(project.title))
              expect(page).to have_content("1 project selected out of 1 for #{category.translated_name}")
              expect(page).to have_content("0 projects selected out of 1 for #{other_category.translated_name}")
              expect(page).to have_button("Vote", disabled: true)
            end
          end
        end
      end

      context "and has pending order" do
        let!(:order) { create(:order, user: user, component: component) }
        let!(:line_item) { create(:line_item, order: order, project: project) }

        it "removes a project from the current order" do
          visit_component

          within ".budget-summary" do
            within "#order-progress" do
              expect(page).to have_content("50%")
              expect(page).to have_button("Vote", disabled: true)
            end

            within "#order-selected-projects" do
              expect(page).to have_content(translated_attribute(project.title))
              expect(page).to have_content("1 project selected out of 1 for #{category.translated_name}")
              expect(page).to have_content("0 projects selected out of 1 for #{other_category.translated_name}")
              expect(page).to have_button("Vote", disabled: true)
            end
          end

          within "#projects" do
            expect(page).to have_selector ".budget-list__data--added", count: 1

            within "#project-#{project.id}-item" do
              find("*[type=submit]").click
            end

            expect(page).to have_no_selector ".budget-list__data--added"
          end

          within ".budget-summary" do
            within "#order-progress" do
              expect(page).to have_content("0%")
              expect(page).to have_button("Vote", disabled: true)
            end

            within "#order-selected-projects" do
              expect(page).not_to have_content(translated_attribute(project.title))
              expect(page).to have_content("0 projects selected out of 1 for #{category.translated_name}")
              expect(page).to have_content("0 projects selected out of 1 for #{other_category.translated_name}")
              expect(page).to have_button("Vote", disabled: true)
            end
          end
        end

        context "and add another project without reaching the minimum projects per category treshold" do
          let!(:other_project) { projects.last }

          it "cannot complete the checkout process" do
            visit_component

            within ".budget-summary" do
              within "#order-progress" do
                expect(page).to have_content("50%")
                expect(page).to have_button("Vote", disabled: true)
              end

              within "#order-selected-projects" do
                expect(page).to have_content(translated_attribute(project.title))
                expect(page).to have_content("1 project selected out of 1 for #{category.translated_name}")
                expect(page).to have_content("0 projects selected out of 1 for #{other_category.translated_name}")
                expect(page).to have_button("Vote", disabled: true)
              end
            end

            within "#projects" do
              expect(page).to have_selector ".budget-list__data--added", count: 1

              within "#project-#{other_project.id}-item" do
                find("*[type=submit]").click
              end

              expect(page).to have_selector ".budget-list__data--added", count: 2
            end

            within ".budget-summary" do
              within "#order-progress" do
                expect(page).to have_content("100%")
                expect(page).to have_button("Vote", disabled: true)
              end

              within "#order-selected-projects" do
                expect(page).to have_content(translated_attribute(project.title))
                expect(page).to have_content(translated_attribute(other_project.title))
                expect(page).to have_content("2 projects selected out of 1 for #{category.translated_name}")
                expect(page).to have_content("0 projects selected out of 1 for #{other_category.translated_name}")
                expect(page).to have_button("Vote", disabled: true)
              end
            end
          end
        end

        context "and add another project reaching the minimum projects per category treshold" do
          let!(:other_project) { create(:project, component: component, budget: 50_000_000, category: other_category) }

          it "can complete the checkout process" do
            visit_component

            within ".budget-summary" do
              within "#order-progress" do
                expect(page).to have_content("50%")
                expect(page).to have_button("Vote", disabled: true)
              end

              within "#order-selected-projects" do
                expect(page).to have_content(translated_attribute(project.title))
                expect(page).to have_content("1 project selected out of 1 for #{category.translated_name}")
                expect(page).to have_content("0 projects selected out of 1 for #{other_category.translated_name}")
                expect(page).to have_button("Vote", disabled: true)
              end
            end

            within "#projects" do
              expect(page).to have_selector ".budget-list__data--added", count: 1

              within "#project-#{other_project.id}-item" do
                find("*[type=submit]").click
              end

              expect(page).to have_selector ".budget-list__data--added", count: 2
            end

            within ".budget-summary" do
              within "#order-progress" do
                expect(page).to have_content("100%")
                expect(page).to have_button("Vote", disabled: false)
              end

              within "#order-selected-projects" do
                expect(page).to have_content("1 project selected out of 1 for #{category.translated_name}")
                expect(page).to have_content("1 project selected out of 1 for #{other_category.translated_name}")
                expect(page).to have_button("Vote", disabled: false)
              end
            end

            within "#order-selected-projects" do
              click_button("Vote")
            end

            within "#budget-confirm", visible: true do
              page.find(".button.expanded").click
            end

            expect(page).to have_content("successfully")

            within ".budget-summary" do
              expect(page).to have_no_button("Vote")
            end
          end
        end
      end
    end
  end
end
