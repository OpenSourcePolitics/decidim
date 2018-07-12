# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe NavbarLinkForm do
      subject { described_class.from_params(attributes) }

      let(:title) do
        {
          en: "Title",
          es: "Título",
          ca: "Títol"
        }
      end

      let(:link) { ::Faker::Internet.url }
      let(:weight) { (1..10).to_a.sample }
      let(:organization) { create(:organization) }
      let(:target) { ["blank", ""].sample }

      let(:attributes) do
        {
          "navbar_link" => {
            "title"        => title,
            "link"         => link,
            "weight"       => weight,
            "target"       => target,
            "organization" => organization
          }
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when default language in title is missing" do
        let(:title) do
          {
            es: "Título",
            ca: "Títol"
          }
        end
        it { is_expected.to be_invalid }
      end

      context "when title is missing" do
        let(:title) { nil }
        it { is_expected.to be_invalid }
      end

      context "when link is missing" do
        let(:link) { nil }
        it { is_expected.to be_invalid }
      end

      it "it should raise error" do
        subject.link = nil
        expect(subject.errors[:link]).not_to be_empty
      end

      context "when weight is missing" do
        let(:weight) { nil }
        it { is_expected.to be_invalid }
      end

      context "when organization is missing" do
        let(:organization) { nil }
        it { is_expected.to be_invalid }
      end

      context "when link has wrong format" do
        let(:link) { "@foo" }
        it { is_expected.to be_invalid }
      end
    end

  end
end
