# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe ChildAssembliesHelper do
    let!(:participatory_space) { create :assembly, organization: organization }
    let!(:child1) { create :assembly, organization: organization, title: { en: "1.1 Afgh" }, parent: participatory_space }
    let!(:child2) { create :assembly, organization: organization, title: { en: "2.3 Defg" }, parent: participatory_space }
    let!(:child3) { create :assembly, organization: organization, title: { en: "1.3 Zhoro" }, parent: participatory_space }
    let!(:unpublished_child_assembly) { create :assembly, :unpublished, organization: organization, parent: participatory_space }
    let!(:organization) { create :organization }

    describe "#child_assemblies_collection" do
      subject { helper.child_assemblies_collection(participatory_space) }

      it { is_expected.to be_truthy }

      it "contains all the published children" do
        expect(subject.count).to eq(3)
        expect(subject).to contain_exactly(child1, child2, child3)
      end

      it "doesn't include the unpublished child" do
        expect(subject).not_to include(unpublished_child_assembly)
      end

      context "when sort_children attribute is true" do
        let!(:participatory_space) { create :assembly, organization: organization, sort_children: true }

        it "sorts the children by title" do
          expect(subject).to eq([child1, child3, child2])
        end

        context "when the sorted_by parameter is defined" do
          subject { helper.child_assemblies_collection(participatory_space, :id) }

          it "sorts the children by id" do
            expect(subject).to eq([child1, child2, child3])
          end
        end
      end

      context "when there is no child assemblies" do
        subject { helper.child_assemblies_collection(assembly_without_children) }

        let!(:assembly_without_children) { create :assembly, organization: organization }

        it "returns empty object" do
          expect(subject).to be_empty
        end
      end
    end
  end
end
