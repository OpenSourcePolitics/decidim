# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe PseudomizeResourcesGeneratorJob do
    subject { described_class }

    let(:component) { proposal_component }
    let(:proposal_component) { create(:proposal_component) }
    let!(:proposal) { create(:proposal, component: component) }
    let!(:comment) { create(:comment, commentable: proposal) }

    describe "perform" do
      it "enqueues the jobs" do
        expect { subject.perform_now(component) }.to have_enqueued_job(Decidim::PseudomizeResourceAuthorsJob).exactly(:twice)
      end
    end

    describe "#resources" do
      it "returns resources" do
        expect(subject.new(component).send(:resources, component)).to match_array([comment, proposal])
      end
    end

    describe "#resources_for_component" do
      it "returns resources_for_component" do
        expect(subject.new(component).send(:resources_for, component)).to match_array([proposal])
      end
    end

    describe "#comments_for" do
      it "returns comments_for" do
        expect(subject.new(component).send(:comments_for, proposal)).to match_array([comment])
      end
    end

    describe "#resources_class" do
      it "returns resources_class for given component" do
        expect(subject.new(component).send(:resources_class, component)).to eq("Decidim::Proposals::Proposal")
      end
    end
  end
end
