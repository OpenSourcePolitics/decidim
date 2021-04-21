# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe InitiativesArchiveCategory do
    subject { base_archive_category.valid? }

    let(:name) { "my category" }
    let(:organization) { create(:organization) }
    let(:archive_category) { build(:archive_category, name: name, organization: organization) }
    let(:base_archive_category) { archive_category }

    it "is valid" do
      expect(archive_category).to be_valid
    end

    context "when name is empty" do
      let(:name) { nil }

      it { is_expected.to be_falsy }
    end

    context "when name is empty" do
      let!(:archive_category) { create(:archive_category, name: name, organization: organization) }
      let(:new_archive_category) { build(:archive_category, name: name, organization: organization) }
      let(:base_archive_category) { new_archive_category }

      it { is_expected.to be_falsy }
    end
  end
end
