# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe AreaForm do
      subject { described_class.from_params(attributes).with_context(context) }

      let(:organization) { create :organization }
      let(:name) { Decidim::Faker::Localized.word }
      let(:area_type) { create :area_type, organization: organization }
      let(:area_type_id) { area_type.id }
      let(:color) { "#efaa4d" }
      let(:logo) { Decidim::Dev.test_file("icon.png", "image/png") }
      let(:attributes) do
        {
          "area" => {
            "name" => name,
            "area_type_id" => area_type_id,
            "color" => color,
            "logo" => logo
          }
        }
      end
      let(:context) do
        {
          "current_organization" => organization
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when name is missing" do
        let(:name) { {} }

        it { is_expected.to be_invalid }
      end

      context "when name is not unique" do
        context "and area_type is not defined" do
          let(:area_type_id) { nil }

          before do
            create(:area, organization: organization, name: name)
          end

          it "is not valid" do
            expect(subject).not_to be_valid
            expect(subject.errors[:name]).not_to be_empty
          end
        end

        context "and area_type is the same" do
          before do
            create(:area, organization: organization, name: name, area_type: area_type)
          end

          it "is not valid" do
            expect(subject).not_to be_valid
            expect(subject.errors[:name]).not_to be_empty
          end
        end

        context "and area_type is different" do
          before do
            create(:area, organization: organization, name: name)
          end

          it "is valid" do
            expect(subject).to be_valid
          end
        end
      end

      context "when the name exists in another organization" do
        before do
          create(:area, name: name)
        end

        it { is_expected.to be_valid }
      end

      context "when color has not hexadecimal format" do
        let(:color) { "not hexadecimal format" }

        it { is_expected.not_to be_valid }
      end

      context "when logo has not png format" do
        let(:logo) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
