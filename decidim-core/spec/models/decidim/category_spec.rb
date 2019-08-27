# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Category do
    subject { category }

    let(:category) { build(:category) }

    it { is_expected.to be_valid }

    context "when it has a parent" do
      let(:category) { create(:subcategory) }

      it { is_expected.to be_valid }
    end

    context "when its parent has a parent" do
      let(:subcategory) { create(:subcategory) }
      let(:category) { build(:category, parent: subcategory) }

      it { is_expected.not_to be_valid }

      it "adds an error" do
        subject.valid?
        expect(subject.errors[:parent_id]).to eq ["can't be inside of a subcategory"]
      end
    end

    context "without a participatory space" do
      let(:parent) { create(:category) }
      let(:category) { create(:subcategory, parent: parent, participatory_space: nil) }

      it "is saved to parent before save" do
        subject.save
        expect(subject.participatory_space).to eq parent.participatory_space
      end
    end

    context "with a color" do
      let(:color) { "#4286f4" }
      let!(:category) { create(:category, color: color) }

      it { is_expected.to be_valid }
      it "return the category color" do
        expect(category.color).to eq(color)
      end

      context "when category has no color" do
        let!(:category) { create(:category, color: nil) }

        it "returns nil" do
          expect(category.color).to eq(nil)
        end

        context "when category has a parent" do
          let!(:parent) { create(:category, color: nil) }
          let!(:category) { create(:category, color: nil, parent: parent) }

          it "returns nil" do
            expect(category.color).to eq(nil)
          end

          context "when parent has a color" do
            let(:parent_color) { "#333333" }
            let!(:parent) { create(:category, color: parent_color) }

            it "returns the parent color" do
              expect(category.color).to eq(parent_color)
            end
          end
        end
      end
    end
  end
end
