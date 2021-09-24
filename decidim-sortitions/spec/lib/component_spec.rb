# frozen_string_literal: true

require "spec_helper"

describe "Sortitions component" do # rubocop:disable RSpec/DescribeClass
  let!(:component) { create(:sortition_component) }
  let!(:current_user) { create(:user, :admin, organization: component.participatory_space.organization) }

  describe "on pseudomize" do
    it "sets comments_enabled as false" do
      Decidim::Admin::PseudomizeComponent.call(current_user, component)

      expect(component.settings.comments_enabled?).to eq(false)
    end
  end
end
