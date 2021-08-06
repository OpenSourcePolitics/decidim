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

    describe "perform" do
      it "enqueues the jobs" do
        expect { subject.perform_now(admin, component) }.to have_enqueued_job(Decidim::PseudomizeResourceAuthorsJob).exactly(:twice)
        expect { subject.perform_now(admin, component) }.to have_enqueued_job(Decidim::EndOfPseudomizeResourcesTaskJob).exactly(:once)
      end
    end

    describe "#resources" do
      it "returns resources" do
        expect(subject.new(admin, component).send(:resources, component)).to match_array([comment, proposal])
      end
    end

    describe "#resources_for_component" do
      it "returns resources_for_component" do
        expect(subject.new(admin, component).send(:resources_for, component)).to match_array([proposal])
      end
    end

    describe "#comments_for" do
      it "returns comments_for" do
        expect(subject.new(admin, component).send(:comments_for, proposal)).to match_array([comment])
      end
    end

    describe "#resources_class" do
      it "returns resources_class for given component" do
        expect(subject.new(admin, component).send(:resources_class, component)).to eq("Decidim::Proposals::Proposal")
      end
    end

    describe "#write_to_cache" do
      let(:cache_entry) { "pseudomize_resources_#{component.manifest_name}" }

      before do
        subject.new(admin, component).send(:write_to_cache, cache_entry, [proposal, comment])
      end

      after do
        Rails.cache.clear
      end

      it "writes to cache" do
        expect(Rails.cache.fetch(cache_entry)).to eq(total: 2, current: 0)
      end
    end
  end
end
