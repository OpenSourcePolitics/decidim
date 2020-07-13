# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe InitiativeAnswerForm do
        subject { described_class.from_model(initiative).with_context(context) }

        let(:organization) { create(:organization) }
        let(:initiatives_type) { create(:initiatives_type, organization: organization) }
        let(:scope) { create(:initiatives_type_scope, type: initiatives_type) }

        let(:state) { "published" }
        let(:answer_date) { nil }

        let(:initiative) { create(:initiative, organization: organization, state: state, answer_date: answer_date, scoped_type: scope) }
        let(:user) { create(:user, organization: organization) }

        let(:context) do
          {
            current_user: user,
            current_organization: organization,
            initiative: initiative
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when answer_date is provided" do
          context "when in a manual state" do
            let(:answer_date) { Date.current - 2.days }
            let(:state) { "examinated" }

            it { is_expected.to be_valid }

            context "when answer_date is in the future" do
              let(:answer_date) { Date.current + 2.days }

              it { is_expected.to be_invalid }
            end

            context "when answer_date is the current day" do
              let(:answer_date) { Date.current }

              it { is_expected.to be_valid }
            end
          end
        end

        describe "#state_updatable?" do
          subject { described_class.from_model(initiative).with_context(context).state_updatable? }

          context "when created" do
            let(:state) { "created" }

            it { is_expected.to eq(false) }
          end

          context "when examinated" do
            let(:state) { "examinated" }

            it { is_expected.to eq(true) }
          end

          context "when published" do
            it { is_expected.to eq(true) }
          end
        end

        describe "#state_validation" do
          let(:answer_date) { Date.current }
          let(:state) { "examinated" }

          it { is_expected.to be_valid }
        end
      end
    end
  end
end
