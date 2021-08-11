# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe PseudomizeComponent do
    subject { described_class.new(user, component) }

    let(:component) { proposal_component }
    let(:user) { create(:user, organization: proposal_component.organization) }
    let(:proposal_component) { create(:proposal_component) }

    describe "#call" do
      it "enqueues the jobs" do
        expect { subject.call }.to have_enqueued_job(Decidim::PseudomizeResourcesGeneratorJob).exactly(:once)
      end
    end
  end
end
