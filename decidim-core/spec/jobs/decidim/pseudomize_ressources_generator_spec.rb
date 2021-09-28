# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe PseudomizeResourcesGeneratorJob do
    subject { described_class }

    let(:component) { proposal_component }
    let(:proposal_component) { create(:proposal_component) }
    let(:admin) { create(:user, :admin, organization: component.organization) }
    let!(:proposal) { create(:proposal, component: component) }
    let!(:comment) { create(:comment, commentable: proposal) }
    let!(:sub_comment) { create(:comment, commentable: comment) }
    let(:resources) { [proposal, comment, sub_comment] }

    describe "perform" do
      before do
        component.update!(pseudomize_status: { current: 0, total: 3 })
      end

      it "shadows the users" do
        expect { subject.perform_now(admin, component, resources) }.to change(Decidim::User.where(shadow: true), :count).by(3)
      end

      it "enqueues the job" do
        expect { subject.perform_now(admin, component, resources) }.to have_enqueued_job(Decidim::EndOfPseudomizeResourcesTaskJob).exactly(:once)
      end

      it "updates the component pseudomize status" do
        subject.perform_now(admin, component, resources)

        component.reload
        expect(component.pseudomize_status).to eq("current" => 3, "total" => 3)
      end

      it "transfers action log owner to pseudomized user" do
        expect { subject.perform_now(admin, component, resources) }.to change(Decidim::ActionLog, :count).by(1)
      end
    end
  end
end
