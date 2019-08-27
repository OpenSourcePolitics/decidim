# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

module Decidim
  describe Admin::FormBuilder do
    let(:subject) { Nokogiri::HTML(output) }

    let(:helper) { Class.new(ActionView::Base).new }
    let(:available_locales) { %w(ca en de-CH) }

    let(:resource) do
      Class.new do
        def self.model_name
          ActiveModel::Name.new(self, nil, "dummy")
        end

        include ActiveModel::Model
        include Virtus.model

        attribute :category_id, Integer
        attribute :projects_per_category_treshold, Hash
      end.new
    end

    let(:builder) { Admin::FormBuilder.new(:resource, resource, helper, {}) }

    before do
      allow(Decidim).to receive(:available_locales).and_return available_locales
      allow(I18n.config).to receive(:enforce_available_locales).and_return(false)
    end

    describe "#autocomplete_select" do
      let(:category) { nil }
      let(:selected) { category }
      let(:options) { {} }
      let(:prompt_options) { { url: "/some/url", text: "Pick a category" } }
      let(:output) { builder.autocomplete_select(:category_id, selected, options, prompt_options) }
      let(:autocomplete_data) { JSON.parse(subject.xpath("//div[@data-autocomplete]/@data-autocomplete").first.value) }

      it "sets the plugin data attribute" do
        expect(subject.css("div[data-plugin='autocomplete']")).not_to be_empty
      end

      it "sets the autocomplete data attribute" do
        expect(subject.css("div[data-autocomplete]")).not_to be_empty
      end

      it "sets the autocomplete_for data attribute" do
        expect(subject.css("div[data-autocomplete-for='category_id']")).not_to be_empty
      end

      context "without selected value" do
        it "renders autocomplete data attribute correctly" do
          expect(autocomplete_data).to eq(
            "name" => "resource[category_id]",
            "noResultsText" => t("autocomplete.no_results", scope: "decidim.admin"),
            "options" => [],
            "placeholder" => nil,
            "searchPromptText" => t("autocomplete.search_prompt", scope: "decidim.admin"),
            "searchURL" => "/some/url",
            "selected" => ""
          )
        end
      end

      context "with selected value" do
        let!(:component) { create(:component) }
        let!(:category) { create(:category, name: { "en" => "Nice category" }, participatory_space: component.participatory_space) }
        let(:output) do
          builder.autocomplete_select(:category_id, selected, options, prompt_options) do |category|
            { value: category.id, label: category.name["en"] }
          end
        end

        it "renders autocomplete data attribute correctly" do
          expect(autocomplete_data["options"]).to eq [{ "value" => category.id, "label" => "Nice category" }]
          expect(autocomplete_data["selected"]).to eq category.id
        end
      end

      context "with custom class" do
        let(:options) { { class: "autocomplete-field--results-inline" } }

        it "sets the class attribute" do
          expect(subject.css(".autocomplete-field--results-inline")).not_to be_empty
        end
      end

      context "with custom name" do
        let(:options) { { name: "custom[name]" } }

        it "configures the select with the custom name" do
          expect(autocomplete_data["name"]).to eq "custom[name]"
        end
      end

      context "with custom label" do
        let(:options) { { label: "custom label" } }

        it "outputs a custom label" do
          expect(subject.xpath("//label").first.text).to eq "custom label"
        end
      end

      context "with label disabled" do
        let(:options) { { label: false } }

        it "doesn't output the label" do
          expect(subject.xpath("//label")).to be_empty
        end
      end
    end

    shared_examples "rendering projects_per_category_treshold_fields" do
      let(:label) { subject.css("label[for*='projects_per_category_treshold']") }
      let(:input_attributes) { label.css("input").first.attributes }

      it "sets the label text correctly" do
        expect(subject.text).to eq(category.translated_name)
      end

      it "sets the input type correctly" do
        expect(input_attributes["type"].value).to eq("number")
      end

      it "sets the min value correctly" do
        expect(input_attributes["min"].value).to eq("0")
      end

      it "sets the max value correctly" do
        expect(input_attributes["max"].value).to eq(input_max_value) if defined?(input_max_value)
      end

      it "sets the input classes correctly" do
        expect(input_attributes["class"].value).to eq("per-category-rule")
      end

      it "sets the input name correctly" do
        expect(input_attributes["name"].value).to eq("resource[projects_per_category_treshold][#{category.id}]")
      end

      it "sets the input ID correctly" do
        expect(input_attributes["id"].value).to eq("resource_projects_per_category_treshold_#{category.id}")
      end

      it "sets the input value correctly" do
        value = defined?(input_value) ? input_value : "0"
        expect(input_attributes["value"].value).to eq(value)
      end
    end

    describe "#projects_per_category_treshold_fields" do
      let(:output) { builder.projects_per_category_treshold_fields(categories, total_projects) }
      let!(:category) { create(:category) }
      let(:total_projects) { nil }

      context "without categories" do
        let(:categories) { Decidim::Category.none }

        it "doesn't render input field" do
          expect(subject.xpath("//label")).to be_empty
        end
      end

      context "with categories" do
        let(:categories) { Decidim::Category.all }
        let(:projects_per_category_treshold) { { category.id.to_s => 1.to_s } }

        it_behaves_like "rendering projects_per_category_treshold_fields"

        context "with projects count value" do
          let(:total_projects) { 1 }

          it_behaves_like "rendering projects_per_category_treshold_fields" do
            let(:input_max_value) { "1" }
          end
        end

        context "with previous value" do
          before do
            resource.projects_per_category_treshold = projects_per_category_treshold
          end

          it_behaves_like "rendering projects_per_category_treshold_fields" do
            let(:input_value) { resource.projects_per_category_treshold.values.first }
          end
        end
      end
    end
  end
end
