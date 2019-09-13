# frozen_string_literal: true

shared_examples "orders" do |*options|
  include Decidim::TranslationsHelper

  let(:manifest_name) { "budgets" }

  let!(:user) { create :user, :confirmed, organization: organization }
  let(:project) { projects.first }

  let!(:component) do
    create(:budget_component,
           :with_total_budget_and_vote_threshold_percent,
           manifest: manifest,
           participatory_space: participatory_process)
  end

  context "when the user is not logged in" do
    let!(:projects) { create_list(:project, 1, component: component, budget: 25_000_000) }

    it "is given the option to sign in" do
      visit_component

      within "#project-#{project.id}-item" do
        find("*[type=submit]").click
      end

      expect(page).to have_css("#loginModal", visible: true)
    end
  end

  context "when the user is logged in" do
    context "when voting by budget" do
      if options.include? :total_budget
        let!(:projects) { create_list(:project, 3, component: component, budget: 25_000_000) }

        before do
          login_as user, scope: :user
        end

        context "and has not a pending order" do
          it "adds a project to the current order" do
            visit_component

            within ".budget-summary" do
              within "#order-progress" do
                expect(page).to have_content "0%"
                expect(page).to have_button("Vote", disabled: true)
                expect(page).to have_content "ASSIGNED: €0"
              end

              within "#order-selected-projects" do
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
                expect(page).to have_content "25%"
                expect(page).to have_button("Vote", disabled: true)
                expect(page).to have_content "ASSIGNED: €25,000,000"
              end

              within "#order-selected-projects" do
                expect(page).to have_content(translated_attribute(project.title))
                expect(page).to have_button("Vote", disabled: true)
              end
            end
          end
        end

        context "and isn't authorized" do
          before do
            permissions = {
              vote: {
                authorization_handler_name: "dummy_authorization_handler"
              }
            }

            component.update!(permissions: permissions)
          end

          it "shows a modal dialog" do
            visit_component

            within "#project-#{project.id}-item" do
              find("*[type=submit]").click
            end

            expect(page).to have_content("Authorization required")
          end
        end

        context "and has pending order" do
          let!(:order) { create(:order, user: user, component: component) }
          let!(:line_item) { create(:line_item, order: order, project: project) }

          it "removes a project from the current order" do
            visit_component

            within ".budget-summary" do
              within "#order-progress" do
                expect(page).to have_content "25%"
                expect(page).to have_button("Vote", disabled: true)
                expect(page).to have_content "ASSIGNED: €25,000,000"
              end

              within "#order-selected-projects" do
                expect(page).to have_content(translated_attribute(project.title))
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
                expect(page).to have_content "0%"
                expect(page).to have_button("Vote", disabled: true)
                expect(page).to have_content "ASSIGNED: €0"
              end

              within "#order-selected-projects" do
                expect(page).not_to have_content(translated_attribute(project.title))
                expect(page).to have_button("Vote", disabled: true)
              end
            end
          end

          context "and try to vote a project that exceed the total budget" do
            let!(:expensive_project) { create(:project, component: component, budget: 250_000_000) }

            it "cannot add the project" do
              visit_component

              within "#project-#{expensive_project.id}-item" do
                find("*[type=submit]").click
              end

              within "#limit-excess", visible: true do
                expect(page).to have_content("Maximum budget exceeded")
              end
            end
          end

          context "and add another project exceeding vote threshold" do
            let!(:other_project) { create(:project, component: component, budget: 50_000_000) }

            it "can complete the checkout process" do
              visit_component

              within ".budget-summary" do
                within "#order-progress" do
                  expect(page).to have_content "25%"
                  expect(page).to have_button("Vote", disabled: true)
                  expect(page).to have_content "ASSIGNED: €25,000,000"
                end

                within "#order-selected-projects" do
                  expect(page).to have_content(translated_attribute(project.title))
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
                  expect(page).to have_content "75%"
                  expect(page).to have_button("Vote", disabled: false)
                  expect(page).to have_content "ASSIGNED: €75,000,000"
                end

                within "#order-selected-projects" do
                  expect(page).to have_content(translated_attribute(project.title))
                  expect(page).to have_content(translated_attribute(other_project.title))
                  expect(page).to have_button("Vote", disabled: false)
                end
              end

              within ".budget-summary #order-progress" do
                click_button("Vote")
              end

              within "#budget-confirm", visible: true do
                click_button("Confirm")
              end

              expect(page).to have_content("successfully")

              within ".budget-summary" do
                expect(page).not_to have_button("Vote")
              end
            end
          end
        end

        context "and has a finished order" do
          let!(:order) do
            order = create(:order, user: user, component: component)
            order.projects = projects
            order.checked_out_at = Time.current
            order.save!
            order
          end

          it "can cancel the order" do
            visit_component

            within ".budget-summary" do
              accept_confirm { page.find(".cancel-order").click }
            end

            expect(page).to have_content("successfully")

            within ".budget-summary" do
              expect(page).to have_button("Vote", disabled: true)
            end
          end
        end

        context "and votes are disabled" do
          let!(:component) do
            create(:budget_component,
                   :with_votes_disabled,
                   manifest: manifest,
                   participatory_space: participatory_process)
          end

          it "cannot create new orders" do
            visit_component

            expect(page).to have_selector("button.budget--list__action[disabled]", count: 3)
            expect(page).to have_no_selector(".budget-summary")
          end
        end

        context "and show votes are enabled" do
          let!(:component) do
            create(:budget_component,
                   :with_show_votes_enabled,
                   manifest: manifest,
                   participatory_space: participatory_process)
          end

          let!(:order) do
            order = create(:order, user: user, component: component)
            order.projects = projects
            order.checked_out_at = Time.current
            order.save!
            order
          end

          it "displays the number of votes for a project" do
            visit_component

            within "#project-#{project.id}-item" do
              expect(page).to have_content("1 SUPPORT")
            end
          end
        end
      end
    end

    context "when voting by project" do
      if options.include? :total_projects
        let(:component) do
          create(:budget_component,
                 :with_vote_per_project,
                 total_projects: 5,
                 manifest: manifest,
                 participatory_space: participatory_process)
        end
        let!(:projects) { create_list(:project, 5, component: component, budget: 25_000_000) }

        before do
          login_as user, scope: :user
        end

        context "and has not a pending order" do
          it "adds a project to the current order" do
            visit_component

            within ".budget-summary" do
              within "#order-progress" do
                expect(page).to have_content "0%"
                expect(page).to have_button("Vote", disabled: true)
              end

              within "#order-selected-projects" do
                expect(page).to have_content "0 projects selected out of a total of 5 projects"
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
                expect(page).to have_content "20%"
                expect(page).to have_button("Vote", disabled: true)
              end

              within "#order-selected-projects" do
                expect(page).to have_content(translated_attribute(project.title))
                expect(page).to have_content "1 project selected out of a total of 5 projects"
                expect(page).to have_button("Vote", disabled: true)
              end
            end
          end
        end

        context "and isn't authorized" do
          before do
            permissions = {
              vote: {
                authorization_handler_name: "dummy_authorization_handler"
              }
            }

            component.update!(permissions: permissions)
          end

          it "shows a modal dialog" do
            visit_component

            within "#project-#{project.id}-item" do
              find("*[type=submit]").click
            end

            expect(page).to have_content("Authorization required")
          end
        end

        context "and has pending order" do
          let!(:order) { create(:order, user: user, component: component) }
          let!(:line_item) { create(:line_item, order: order, project: project) }

          it "removes a project from the current order" do
            visit_component

            within "#order-selected-projects" do
              expect(page).to have_content "1 project selected out of a total of 5 projects"
            end

            expect(page).to have_selector ".budget-list__data--added", count: 1

            within "#project-#{project.id}-item" do
              find("*[type=submit]").click
            end

            expect(page).to have_no_selector ".budget-list__data--added"

            within "#order-selected-projects" do
              expect(page).to have_content "0 projects selected out of a total of 5 projects"
            end
          end

          context "when projects number exceed limit" do
            let!(:other_project) { create(:project, component: component, budget: 50_000_000) }
            let!(:line_item_two) { create(:line_item, order: order, project: projects[1]) }
            let!(:line_item_three) { create(:line_item, order: order, project: projects[2]) }
            let!(:line_item_four) { create(:line_item, order: order, project: projects[3]) }
            let!(:line_item_five) { create(:line_item, order: order, project: projects[4]) }

            it "cannot add another project" do
              visit_component

              within "#project-#{other_project.id}-item" do
                find("*[type=submit]").click
              end

              within "#limit-excess", visible: true do
                expect(page).to have_content("Maximum number of projects reached")
              end
            end
          end
        end

        context "and has a finished order" do
          let!(:order) do
            order = create(:order, user: user, component: component)
            order.projects = projects
            order.checked_out_at = Time.current
            order.save!
            order
          end

          it "can cancel the order" do
            visit_component

            within ".budget-summary" do
              accept_confirm { page.find(".cancel-order").click }
            end

            expect(page).to have_content("successfully")

            within ".budget-summary" do
              expect(page).to have_content("0 projects selected out of a total of 5 projects")
              expect(page).to have_button("Vote", disabled: true)
            end
          end
        end

        context "and votes are disabled" do
          let!(:component) do
            create(:budget_component,
                   :with_votes_disabled,
                   :with_vote_per_project,
                   manifest: manifest,
                   participatory_space: participatory_process)
          end

          it "cannot create new orders" do
            visit_component

            expect(page).to have_selector("button.budget--list__action[disabled]", count: 5)
            expect(page).to have_no_selector(".budget-summary")
          end
        end

        context "and show votes are enabled" do
          let!(:component) do
            create(:budget_component,
                   :with_show_votes_enabled,
                   :with_vote_per_project,
                   manifest: manifest,
                   participatory_space: participatory_process)
          end

          let!(:order) do
            order = create(:order, user: user, component: component)
            order.projects = projects
            order.checked_out_at = Time.current
            order.save!
            order
          end

          it "displays the number of votes for a project" do
            visit_component

            within "#project-#{project.id}-item" do
              expect(page).to have_content("1 SUPPORT")
            end
          end
        end
      end
    end
  end

  describe "index" do
    context "when category has color" do
      let(:color) { "#ffffff" }
      let!(:category) { create(:category, participatory_space: component.participatory_space, color: color) }
      let!(:project) { create(:project, component: component) }
      let!(:other_project) { create(:project, component: component) }

      it "displays a border" do
        project.update!(category: category)
        visit_component

        expect(page.find("#project-#{project.id}-item").style(:border)).not_to eq("border" => "1px solid rgb(232, 232, 232)")
        expect(page.find("#project-#{other_project.id}-item").style(:border)).to eq("border" => "1px solid rgb(232, 232, 232)")
      end
    end

    context "when voting by budget" do
      if options.include? :total_budget
        let!(:projects) { create_list(:project, 4, budget: 25_000_000, component: component) }

        before do
          login_as user, scope: :user
        end

        it "displays the budget summary" do
          visit_component

          within ".budget-summary" do
            expect(page).to have_css("h3", text: "You decide the budget")
            expect(page).to have_css("p", text: "To which projects do you think we should allocate a budget?")

            within "#order-voting-rules" do
              expect(page).to have_css("h3", text: "Voting rules")
              expect(page).to have_css("p", text: "To complete your ballot you need to select:")
              expect(page).to have_css("li", text: "Assign at least €70,000,000 to the projects you want and vote with your preferences to define the budget.")
            end

            within "#order-progress" do
              expect(page).to have_css("span", text: "TOTAL BUDGET €100,000,000")
              expect(page).to have_css("div.progress-meter")
              expect(page).to have_css("span", text: "ASSIGNED: €0")
              expect(page).to have_css("button", text: "VOTE")
            end

            within "#order-selected-projects" do
              expect(page).to have_css("h3", text: "Your selection")
              expect(page).to have_css("button", text: "VOTE")
            end
          end
        end

        it "displays the minimum vote amount" do
          visit_component

          expect(find(".progress-meter--minimum")[:style]).to eq("width: 30%;")
        end

        context "when no project in order" do
          it "displays the right percentage" do
            visit_component

            within ".progress-meter-text--right" do
              expect(page).to have_content "0%"
            end
          end

          it "doesn't displays the state color" do
            visit_component

            expect(page).not_to have_css(".budget_summary_state--pending")
            expect(page).not_to have_css(".progress_meter_state--pending")
            expect(page).not_to have_css(".budget_summary_state--completed")
            expect(page).not_to have_css(".progress_meter_state--completed")
          end
        end

        context "when half full project in order" do
          let!(:order) do
            order = create(:order, user: user, component: component)
            order.projects << projects.take(2)
            order.save!
            order
          end

          it "displays the right percentage" do
            visit_component

            within ".progress-meter-text--right" do
              expect(page).to have_content "50%"
            end
          end

          it "displays the state color" do
            visit_component

            expect(page).to have_css(".budget_summary_state--pending")
            expect(page).to have_css(".progress_meter_state--pending")
          end
        end

        context "when full project in order" do
          let!(:order) do
            order = create(:order, user: user, component: component)
            order.projects << projects
            order.save!
            order
          end

          it "displays the right percentage" do
            visit_component

            within ".progress-meter-text--right" do
              expect(page).to have_content "100%"
            end
          end

          it "displays the state color" do
            visit_component

            expect(page).to have_css(".budget_summary_state--completed")
            expect(page).to have_css(".progress_meter_state--completed")
          end
        end

        it_behaves_like "orders vote per category"
      end
    end

    context "when voting by project" do
      if options.include? :total_projects
        let!(:component) do
          create(:budget_component,
                 :with_vote_per_project,
                 total_projects: 5,
                 manifest: manifest,
                 participatory_space: participatory_process)
        end

        let!(:projects) { create_list(:project, 5, component: component) }

        before do
          login_as user, scope: :user
        end

        it "displays the budget summary" do
          visit_component

          within ".budget-summary" do
            expect(page).to have_css("h3", text: "You decide the budget")
            expect(page).to have_css("p", text: "To which projects do you think we should allocate a budget?")

            within "#order-voting-rules" do
              expect(page).to have_css("h3", text: "Voting rules")
              expect(page).to have_css("p", text: "To complete your ballot you need to select:")
              expect(page).to have_css("li", text: "5 projects total")
            end

            within "#order-progress" do
              expect(page).to have_css("div.progress-meter")
              expect(page).to have_css("button", text: "VOTE")
            end

            within "#order-selected-projects" do
              expect(page).to have_css("h3", text: "Your selection")
              expect(page).to have_css("li", text: "0 projects selected out of a total of 5 projects")
              expect(page).to have_css("button", text: "VOTE")
            end
          end
        end

        it "displays the minimum vote amount" do
          visit_component

          expect(find(".progress-meter--minimum")[:style]).to eq("width: 100%;")
        end

        context "when no project in order" do
          it "displays the right percentage" do
            visit_component

            within ".progress-meter-text--right" do
              expect(page).to have_content "0%"
            end
          end

          it "displays the state color" do
            visit_component

            expect(page).not_to have_css(".budget_summary_state--pending")
            expect(page).not_to have_css(".progress_meter_state--pending")
            expect(page).not_to have_css(".budget_summary_state--completed")
            expect(page).not_to have_css(".progress_meter_state--completed")
          end
        end

        context "when half full project in order" do
          let!(:order) do
            order = create(:order, user: user, component: component)
            order.projects << projects.take(3)
            order.save!
            order
          end

          it "displays the right percentage" do
            visit_component

            within ".progress-meter-text--right" do
              expect(page).to have_content "60%"
            end
          end

          it "displays the state color" do
            visit_component

            expect(page).to have_css(".budget_summary_state--pending")
            expect(page).to have_css(".progress_meter_state--pending")
          end
        end

        context "when full project in order" do
          let!(:order) do
            order = create(:order, user: user, component: component)
            order.projects << projects
            order.save!
            order
          end

          it "displays the right percentage" do
            visit_component

            within ".progress-meter-text--right" do
              expect(page).to have_content "100%"
            end
          end

          it "displays the state color" do
            visit_component

            expect(page).to have_css(".budget_summary_state--completed")
            expect(page).to have_css(".progress_meter_state--completed")
          end
        end
      end

      it_behaves_like "orders vote per category"
    end

    it "respects the projects_per_page setting when under total projects" do
      component.update!(settings: { projects_per_page: 1 })

      create_list(:project, 2, component: component)

      visit_component

      expect(page).to have_selector("[id^=project-]", count: 1)
    end

    it "respects the projects_per_page setting when it matches total projects" do
      component.update!(settings: { projects_per_page: 2 })

      create_list(:project, 2, component: component)

      visit_component

      expect(page).to have_selector("[id^=project-]", count: 2)
    end

    it "respects the projects_per_page setting when over total projects" do
      component.update!(settings: { projects_per_page: 3 })

      create_list(:project, 2, component: component)

      visit_component

      expect(page).to have_selector("[id^=project-]", count: 2)
    end
  end

  describe "show" do
    let!(:project) { create(:project, component: component, budget: 25_000_000) }

    before do
      visit resource_locator(project).path
    end

    it_behaves_like "has attachments" do
      let(:attached_to) { project }
    end

    it "shows the component" do
      expect(page).to have_i18n_content(project.title)
      expect(page).to have_i18n_content(project.description)
    end

    context "with linked proposals" do
      let(:proposal_component) do
        create(:component, manifest_name: :proposals, participatory_space: project.component.participatory_space)
      end
      let(:proposals) { create_list(:proposal, 3, component: proposal_component) }

      before do
        project.link_resources(proposals, "included_proposals")
      end

      it "shows related proposals" do
        visit_component
        click_link translated(project.title)

        proposals.each do |proposal|
          expect(page).to have_content(proposal.title)
          expect(page).to have_content(proposal.creator_author.name)
          expect(page).to have_content(proposal.votes.size)
        end
      end
    end
  end
end