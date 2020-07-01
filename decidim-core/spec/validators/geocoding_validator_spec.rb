# frozen_string_literal: true

require "spec_helper"

describe GeocodingValidator do
  shared_examples_for "geocoder coordinates computing" do
    it "uses Geocoder to compute its coordinates" do
      expect(subject).to be_valid
      expect(subject.latitude).to eq(latitude)
      expect(subject.longitude).to eq(longitude)
    end
  end

  let(:validatable) do
    Class.new do
      def self.model_name
        ActiveModel::Name.new(self, nil, "Validatable")
      end

      include Virtus.model
      include ActiveModel::Validations

      attribute :address
      attribute :latitude
      attribute :longitude

      validates :address, geocoding: true

      def component
        FactoryBot.create(:component)
      end
    end
  end

  let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  let(:subject) { validatable.new(address: address) }

  context "when the address is valid" do
    before do
      stub_geocoding(address, [latitude, longitude])
    end

    it_behaves_like "geocoder coordinates computing"

    context "when search is restricted to a specific country" do
      before do
        Decidim.geocoder[:country_restriction] = "France"
      end

      it_behaves_like "geocoder coordinates computing"
    end
  end

  context "when the address is not valid" do
    let(:address) { "The post-apocalyptic Land of Ooo" }

    before do
      stub_geocoding(address, [])
    end

    it { is_expected.to be_invalid }
  end
end
