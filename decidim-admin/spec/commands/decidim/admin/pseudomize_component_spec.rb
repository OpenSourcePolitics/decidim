# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe PseudomizeComponent do
    subject { described_class.new(user, component) }

    let(:component) { proposal_component }
    let(:user) { create(:user, organization: proposal_component.organization) }
    let(:proposal_component) { create(:proposal_component) }
    let!(:proposal) { create(:proposal, component: component) }
    let!(:comment) { create(:comment, commentable: proposal) }
    let!(:sub_comment) { create(:comment, commentable: comment) }

    describe "#call" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "enqueues the jobs" do
        expect { subject.call }.to have_enqueued_job(Decidim::PseudomizeResourcesGeneratorJob)
          .with(user, proposal_component, [proposal, comment, sub_comment])
          .exactly(:once)
      end

      it "marks component as running" do
        expect(component.pseudomize_status).to be_nil
        expect { subject.call }.to change(component, :pseudomize_status)
        expect(component.pseudomize_status).to eq("current" => 0, "total" => 3)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:pseudomize, component, user, visibility: "all")
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end

    describe "#all_resources_for" do
      it "returns all_resources_for" do
        expect(subject.send(:all_resources_for, component)).to match_array([sub_comment, comment, proposal])
      end
    end

    describe "#resources_for_component" do
      it "returns resources_for_component" do
        expect(subject.send(:resources_for, component)).to match_array([proposal])
      end
    end

    describe "#comments_for" do
      it "returns comments_for" do
        expect(subject.send(:comments_for, proposal)).to match_array([sub_comment, comment])
      end

      context "when there is a depth equal to 4" do
        let!(:third_sub_comment) { create(:comment, commentable: sub_comment) }
        let!(:fourth_sub_comment) { create(:comment, commentable: third_sub_comment) }

        it "returns all comments" do
          expect(subject.send(:comments_for, proposal)).to match_array([fourth_sub_comment, third_sub_comment, sub_comment, comment])
        end
      end
    end

    describe "#resources_class" do
      it "returns resources_class for given component" do
        expect(subject.send(:resources_class, component)).to eq("Decidim::Proposals::Proposal")
      end
    end
  end
end
