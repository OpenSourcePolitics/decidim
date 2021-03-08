# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativeHelper do
      context "with state_badge_css_class" do
        let(:initiative) { create(:initiative) }

        it "success for accepted initiatives" do
          allow(initiative).to receive(:accepted?).and_return(true)

          expect(helper.state_badge_css_class(initiative)).to eq("success")
        end

        it "warning in any other case" do
          allow(initiative).to receive(:accepted?).and_return(false)
          allow(initiative).to receive(:published?).and_return(false)

          expect(helper.state_badge_css_class(initiative)).to eq("warning")
        end
      end

      context "with humanize_state" do
        let(:initiative) { create(:initiative) }

        it "returns the state translation" do
          [:debatted, :examinated, :classified, :accepted].each do |state|
            initiative.state = state.to_s
            expect(humanize_state(initiative)).to eq(I18n.t(state.to_s, scope: "decidim.initiatives.states"))
          end
        end

        context "with rejected initiative" do
          let(:initiative) { create(:initiative, :rejected) }

          it "expired for rejected initiative" do
            expect(helper.humanize_state(initiative)).to eq(I18n.t("expired", scope: "decidim.initiatives.states"))
          end
        end
      end

      context "with humanize_admin_state" do
        let(:available_states) { [:created, :validating, :discarded, :published, :rejected, :accepted] }

        it "All states have a translation" do
          available_states.each do |state|
            expect(humanize_admin_state(state)).not_to be_blank
          end
        end
      end

      context "with popularity_tag" do
        let(:initiative) { build(:initiative) }

        it "level1 from 0% to 40%" do
          expect(initiative).to receive(:percentage).at_least(:once).and_return(20)
          expect(popularity_tag(initiative)).to include("popularity--level1")
        end

        it "level2 from 40% to 60%" do
          expect(initiative).to receive(:percentage).at_least(:once).and_return(50)
          expect(popularity_tag(initiative)).to include("popularity--level2")
        end

        it "level3 from 60% to 80%" do
          expect(initiative).to receive(:percentage).at_least(:once).and_return(70)
          expect(popularity_tag(initiative)).to include("popularity--level3")
        end

        it "level4 from 80% to 100%" do
          expect(initiative).to receive(:percentage).at_least(:once).and_return(90)
          expect(popularity_tag(initiative)).to include("popularity--level4")
        end

        it "level5 at 100%" do
          expect(initiative).to receive(:percentage).at_least(:once).and_return(100)
          expect(popularity_tag(initiative)).to include("popularity--level5")
        end
      end

      context "#can_be_interacted_with?" do
        let(:subject) { helper.can_be_interacted_with?(initiative) }

        context "when published" do
          let(:initiative) { create(:initiative, :published) }

          it { is_expected.to be_truthy }
        end

        context "when accepted" do
          let(:initiative) { create(:initiative, :accepted) }

          it { is_expected.to be_truthy }
        end

        context "when examinated" do
          let(:initiative) { create(:initiative, :examinated) }

          it { is_expected.to be_truthy }
        end

        context "when debated" do
          let(:initiative) { create(:initiative, :debatted) }

          it { is_expected.to be_truthy }
        end

        context "when classified" do
          let(:initiative) { create(:initiative, :classified) }

          it { is_expected.to be_truthy }
        end

        context "when created" do
          let(:initiative) { create(:initiative, :created) }

          it { is_expected.to be_falsy }
        end
      end

      context "#editable?" do
        let(:subject) { helper.editable?(initiative) }

        context "when validating" do
          let(:initiative) { create(:initiative, :validating) }

          it { is_expected.to be_falsy }
        end

        context "when published" do
          let(:initiative) { create(:initiative, :published) }

          it { is_expected.to be_falsy }
        end

        context "when examinated" do
          let(:initiative) { create(:initiative, :examinated) }

          it { is_expected.to be_falsy }
        end

        context "when classified" do
          let(:initiative) { create(:initiative, :classified) }

          it { is_expected.to be_falsy }
        end

        context "when discarded" do
          let(:initiative) { create(:initiative, :discarded) }

          it { is_expected.to be_falsy }
        end
        context "when rejected" do
          let(:initiative) { create(:initiative, :rejected) }

          it { is_expected.to be_falsy }
        end
        context "when accepted" do
          let(:initiative) { create(:initiative, :accepted) }

          it { is_expected.to be_falsy }
        end

        context "when created" do
          let(:initiative) { create(:initiative, :created) }

          it { is_expected.to be_truthy }
        end
      end
    end
  end
end
