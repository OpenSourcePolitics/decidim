# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe EndOfPseudomizeResourcesTaskJob do
    subject { described_class }

    let(:user) { create(:user) }
    let(:component) { proposal_component }
    let(:proposal_component) { create(:proposal_component) }

    let(:component_cache) { Decidim::PseudomizeResourcesStatusManager.new(component) }

    let(:uncompleted_status) do
      { total: 2, current: 0 }
    end

    let(:completed_status) do
      { total: 2, current: 2 }
    end

    after do
      Rails.cache.clear
    end

    describe "perform" do
      it "send an email to admin" do
        component_cache.write(completed_status)
        allow(Decidim::Admin::PseudomizeMailer).to receive(:notfiy_admin).and_call_original

        subject.perform_now(user, component)

        expect(Decidim::Admin::PseudomizeMailer)
          .to have_received(:notfiy_admin)
          .with(user)
      end

      context "when not completed" do
        it "re-enqueues the job" do
          component_cache.write(uncompleted_status)

          expect { subject.perform_now(user, component) }.to have_enqueued_job(Decidim::EndOfPseudomizeResourcesTaskJob).exactly(:once)
        end
      end
    end
  end
end
