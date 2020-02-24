# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe SettingsHelper do
      let(:options) { {} }
      let(:attribute) { double(type: type, translated?: false, editor?: false) }
      let(:type) { :boolean }
      let(:name) { :test }

      let(:form) do
        double
      end

      def render_input
        helper.settings_attribute_input(form, attribute, name, options)
      end

      describe "booleans" do
        let(:type) { :boolean }

        it "is supported" do
          expect(form).to receive(:check_box).with(:test, options)
          render_input
        end
      end

      describe "numbers" do
        let(:type) { :integer }

        it "is supported" do
          expect(form).to receive(:number_field).with(:test, options)
          render_input
        end
      end

      describe "strings" do
        let(:type) { :string }

        it "is supported" do
          expect(form).to receive(:text_field).with(:test, options)
          render_input
        end
      end

      describe "texts" do
        let(:type) { :text }

        it "is supported" do
          expect(form).to receive(:text_area).with(:test, options)
          render_input
        end
      end

      describe "projects_per_category_treshold_form_field" do
        let(:name) { :projects_per_category_treshold }

        before do
          expect(helper).to receive(:current_participatory_space).and_return(create(:participatory_process))
        end

        it "is supported" do
          expect(form).to receive(:projects_per_category_treshold_fields).with(ActiveRecord::AssociationRelation, Integer)
          render_input
        end
      end
    end
  end
end
