# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe PseudomizeHelper do
      let(:component) { proposal_component }
      let(:pseudomize_status) do
        {
          current: 0,
          total: 2
        }
      end
      let(:proposal_component) { create(:proposal_component, pseudomize_status: pseudomize_status) }

      describe "#pseudomizable?" do
        shared_examples_for "for a component" do |component|
          let(:"#{component}_component") { create(:"#{component}_component") }

          it "returns true for a #{component} component" do
            # rubocop:disable Security/Eval, Style/EvalWithLocation
            expect(helper).to be_pseudomizable(eval("#{component}_component"))
            # rubocop:enable Security/Eval, Style/EvalWithLocation
          end
        end

        %w(debates proposal sortition).each do |component|
          it_behaves_like "for a component", component
        end
      end

      describe "#pseudomization_status" do
        it "returns pseudomize status" do
          expect(helper.pseudomization_status(component)).to eq(pseudomize_status)
        end

        context "when pseudomize_status is not defined" do
          let(:pseudomize_status) { nil }

          it "returns false" do
            expect(helper.pseudomization_status(component)).to be_falsey
          end
        end
      end

      describe "#can_perform_pseudomization?" do
        context "when pseudomize_status is not defined" do
          let(:pseudomize_status) { nil }

          it "returns true" do
            expect(helper).to be_can_perform_pseudomization(component)
          end
        end

        context "when pseudomize_status is running" do
          let(:pseudomize_status) { { current: 2, total: 10 } }

          it "returns falsey" do
            expect(helper).not_to be_can_perform_pseudomization(component)
          end
        end

        context "when pseudomize_status is completed" do
          let(:pseudomize_status) { { current: 10, total: 10 } }

          it "returns falsey" do
            expect(helper).not_to be_can_perform_pseudomization(component)
          end
        end
      end

      describe "#pseudomization_running?" do
        let(:pseudomize_status) { { current: 2, total: 10 } }

        it "returns true" do
          expect(helper).to be_pseudomization_running(component)
        end

        context "when pseudomize_status is not defined" do
          let(:pseudomize_status) { nil }

          it "returns falsey" do
            expect(helper).not_to be_pseudomization_running(component)
          end
        end

        context "when pseudomize_status is not defined" do
          let(:pseudomize_status) { { current: 10, total: 10 } }

          it "returns falsey" do
            expect(helper).not_to be_pseudomization_running(component)
          end
        end
      end

      describe "#pseudomization_completed?" do
        let(:pseudomize_status) { { current: 10, total: 10 } }

        it "returns true" do
          expect(helper).to be_pseudomization_completed(component)
        end

        context "when pseudomize_status is not defined" do
          let(:pseudomize_status) { nil }

          it "returns falsey" do
            expect(helper).not_to be_pseudomization_completed(component)
          end
        end

        context "when pseudomize_status is not defined" do
          let(:pseudomize_status) { { current: 2, total: 10 } }

          it "returns falsey" do
            expect(helper).not_to be_pseudomization_completed(component)
          end
        end
      end

      describe ""
    end
  end
end
