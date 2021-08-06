# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe EndOfPseudomizeResourcesTaskJob do
    subject { described_class }

    let(:user) { create(:user) }
    let(:component) { proposal_component }
    let(:proposal_component) { create(:proposal_component) }
    let(:cache_entry) { "pseudomize_resources_#{component.manifest_name}" }
    let(:cache_hash) do
      { total: 2, current: 0 }
    end

    before do
      Rails.cache.write(cache_entry, cache_hash)
    end

    after do
      Rails.cache.clear
    end

    describe "perform" do
      context "when not completed" do
        it "re-enqueues the job" do
          expect { subject.perform_now(user, cache_entry) }.to have_enqueued_job(Decidim::EndOfPseudomizeResourcesTaskJob).exactly(:once)
        end
      end
    end

    describe "#read_cache_entry" do
      it "returns the current state of the task" do
        expect(subject.new(user, cache_entry).send(:read_cache_entry, cache_entry)).to eq(cache_hash)
      end
    end

    describe "#erase_cache_entry" do
      it "removes cache entry" do
        subject.new(user, cache_entry).send(:erase_cache_entry!, cache_entry)

        expect(Rails.cache.fetch(cache_entry)).to eq(nil)
      end
    end

    describe "#task_completed?" do
      it "returns false" do
        expect(subject.new(user, cache_entry).send(:task_completed?, cache_entry)).to eq(false)
      end

      context "when completed" do
        let(:cache_entry) do
          { total: 2, current: 2 }
        end

        it "returns true" do
          Rails.cache.write(cache_entry, total: 2, current: 2)

          expect(subject.new(user, cache_entry).send(:task_completed?, cache_entry)).to eq(true)
        end
      end

      context "when nil" do
        it "returns true" do
          Rails.cache.write(cache_entry, nil)

          expect(subject.new(user, cache_entry).send(:task_completed?, cache_entry)).to eq(true)
        end
      end
    end
  end
end
