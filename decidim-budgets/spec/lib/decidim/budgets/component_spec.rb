# frozen_string_literal: true

require "spec_helper"

describe "Budgets component" do # rubocop:disable RSpec/DescribeClass
  let!(:component) { create(:budget_component) }
  let!(:projects) { create_list(:project, 2, component: component) }
  let(:participatory_space) { component.participatory_space }
  let!(:user) { create(:user, :admin, organization: participatory_space.organization) }
  let!(:category) { create(:category, participatory_space: participatory_space) }

  describe "voting rules", type: :system do
    let(:routes) { Decidim::EngineRouter.admin_proxy(component.participatory_space) }
    let(:total_budget_field) { find("input#component_settings_total_budget") }
    let(:per_budget_rules_fields) { find_all("input.per-budget-rule") }
    let(:per_project_rules_fields) { find_all("input.per-project-rule") }

    before do
      switch_to_host(component.organization.host)
      login_as user, scope: :user
    end

    shared_examples "showing the voting rules modal on submit" do
      before { find("button[type=submit]").click }

      it "displays the voting-rules-modal" do
        within "#voting-rules-modal", visible: true do
          expect(page).to have_css("h3", text: "There's been a problem with the votings rules!")
          expect(page).to have_css("p", text: "Make sure that the sum of minimums per categories does not amount to more than the value inputed for Number of projects the user has to select: #{total_projects}")
          expect(page).to have_css("p", text: "Make sure that the value of the following fields does not surpass the total number of projects for this component: #{component_projects}")
          expect(page).to have_css("li", text: "Number of projects the user has to select")
          expect(page).to have_css("li", text: "Activate rule: \"minimum projects to select per category\"")
        end
      end
    end

    shared_examples "not showing the voting rules modal on submit" do
      before { find("button[type=submit]").click }

      it "doesn't display the voting-rules-modal" do
        expect(page).not_to have_css("#voting-rules-modal", visible: true)
      end
    end

    shared_examples "voting rules" do
      let!(:new_component?) { find(".form")[:class].include?("new") }
      let!(:component_projects) { new_component? ? 0 : projects.count }
      let!(:total_projects) { component.settings.total_projects }

      it "sets the min value for total_projects to '1'" do
        total_projects_min_value = find("#component_settings_total_projects")["min"]
        expect(total_projects_min_value).to eq("1")
      end

      context "when vote_per_budget is checked (default)" do
        it "disables fields with 'per-project-rule' class" do
          expect(per_project_rules_fields).to all(be_disabled)
        end

        it_behaves_like "not showing the voting rules modal on submit"
      end

      context "when vote_per_project is checked" do
        before do
          uncheck('Activate rule: "minimum budget percentage"')
          check('Activate rule: "number of projects selected"')
        end

        it "disables fields with 'per-budget-rule' class" do
          expect(per_budget_rules_fields).to all(be_disabled)
        end

        it "disables the total_budget field" do
          expect(total_budget_field).to be_disabled
        end

        context "and total_projects value does NOT surpass total component's projects" do
          let(:total_projects) { 1 }

          before do
            skip if new_component?
            fill_in(:component_settings_total_projects, with: total_projects)
          end

          it_behaves_like "not showing the voting rules modal on submit"

          context "when vote_per_category is also checked" do
            before { check('Activate rule: "minimum projects to select per category"') }

            context "and projects_per_category_treshold sum surpass total_projects" do
              before { fill_in(:"component_settings_projects_per_category_treshold_#{category.id}", with: 2) }

              it_behaves_like "showing the voting rules modal on submit"
            end
          end
        end

        context "and total_projects value is less than '1'" do
          let(:total_projects) { 0 }

          before { fill_in(:component_settings_total_projects, with: total_projects) }

          it_behaves_like "showing the voting rules modal on submit"
        end

        context "and total_projects value surpass total component's projects" do
          let(:total_projects) { 3 }

          before { fill_in(:component_settings_total_projects, with: total_projects) }

          it_behaves_like "showing the voting rules modal on submit"
        end
      end

      context "when neither vote_per_project nor vote_per_project is selected" do
        before { uncheck('Activate rule: "minimum budget percentage"') }

        it_behaves_like "showing the voting rules modal on submit"
      end

      context "when vote_per_category is checked" do
        before { check('Activate rule: "minimum projects to select per category"') }

        context "and projects_per_category_treshold sum surpass total component's projects" do
          before { fill_in(:"component_settings_projects_per_category_treshold_#{category.id}", with: 3) }

          it_behaves_like "showing the voting rules modal on submit"
        end

        context "and a projects_per_category_treshold value is less than '0'" do
          before { fill_in(:"component_settings_projects_per_category_treshold_#{category.id}", with: -1) }

          it_behaves_like "showing the voting rules modal on submit"
        end
      end
    end

    describe "on new" do
      let(:new_component_path) { routes.new_component_path(type: component.manifest_name) }

      before { visit new_component_path }

      it_behaves_like "voting rules"
    end

    describe "on edit" do
      let(:edit_component_path) { routes.edit_component_path(component.id) }

      before { visit edit_component_path }

      it_behaves_like "voting rules"
    end
  end
end
