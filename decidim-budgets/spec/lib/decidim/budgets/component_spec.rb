# frozen_string_literal: true

require "spec_helper"

describe "Budgets component" do # rubocop:disable RSpec/DescribeClass
  let!(:component) { create(:budget_component) }
  let!(:current_user) { create(:user, :admin, organization: component.participatory_space.organization) }

  describe "voting rules", type: :system do
    let(:admin_engine) { Decidim::EngineRouter.admin_proxy(component.participatory_space) }
    let(:total_budget_field) { page.find("input#component_settings_total_budget") }
    let(:per_budget_rules_fields) { page.find_all("input.per-budget-rule") }
    let(:per_project_rules_fields) { page.find_all("input.per-project-rule") }

    before do
      switch_to_host(component.organization.host)
      login_as current_user, scope: :user
    end

    shared_examples "vote_per_budget enabled" do
      it "disables fields with 'per-project-rule' class" do
        expect(per_project_rules_fields).to all(be_disabled)
      end
    end

    shared_examples "vote_per_project enabled" do
      it "disables fields with 'per-budget-rule' class" do
        expect(per_budget_rules_fields).to all(be_disabled)
      end

      it "disables the total_budget field" do
        expect(total_budget_field).to be_disabled
      end
    end

    describe "on new" do
      let(:new_component_path) { admin_engine.new_component_path(type: component.manifest.name) }

      context "when vote_per_budget is checked" do
        before do
          visit new_component_path
          check 'Activate rule: "minimum budget percentage"'
        end

        it_behaves_like "vote_per_budget enabled"
      end

      context "when vote_per_project is checked" do
        before do
          visit new_component_path
          check 'Activate rule: "number of projects selected"'
        end

        it_behaves_like "vote_per_project enabled"
      end
    end

    describe "on edit" do
      let(:edit_component_path) { admin_engine.edit_component_path(component.id) }

      context "when vote_per_budget is enabled" do
        before do
          component.update(settings: { vote_per_budget: true })
          visit edit_component_path
        end

        it_behaves_like "vote_per_budget enabled"
      end

      context "when vote_per_project is enabled" do
        before do
          component.update(settings: { vote_per_project: true })
          visit edit_component_path
        end

        it_behaves_like "vote_per_project enabled"
      end
    end
  end
end
