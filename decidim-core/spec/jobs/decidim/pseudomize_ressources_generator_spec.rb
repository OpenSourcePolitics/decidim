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

      context "when user has activity logs" do
        let!(:comment) { create(:comment, commentable: proposal, author: admin) }

        before do
          Decidim.traceability.create!(
            Decidim::Comments::Comment,
            admin,
            {
              author: admin,
              commentable: proposal,
              root_commentable: proposal,
              body: "Comment body"
            },
            resource: component,
            visibility: "public-only"
          )
        end

        it "transfer activities to the pseudomized user" do
          activity_log = Decidim::ActionLog.last
          expect(activity_log.decidim_user_id).to eq(admin.id)
          subject.perform_now(admin, component, resources)
          activity_log.reload
          expect(activity_log.decidim_user_id).not_to eq(admin.id)
        end
      end
    end
  end
end
