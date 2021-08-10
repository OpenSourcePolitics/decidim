# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe PseudomizeResourcesCacheManager do
    subject { described_class.new(component) }

    let(:uncompleted_cache_hash) do
      { total: 2, current: 0 }
    end
    let(:completed_cache_hash) do
      { total: 2, current: 2 }
    end

    let(:running_cache_hash) do
      { pending: true }
    end

    let(:component) { proposal_component }
    let(:proposal_component) { create(:proposal_component) }

    after do
      Rails.cache.clear
    end

    describe "#read_cache_entry" do
      it "returns the current state of the task" do
        subject.write_to_cache(uncompleted_cache_hash)

        expect(subject.read_from_cache).to eq(uncompleted_cache_hash)
      end
    end

    describe "#erase_cache_entry" do
      it "removes cache entry" do
        subject.erase_cache_entry!

        expect(subject.read_from_cache).to eq({})
      end
    end

    describe "#task_completed?" do
      it "returns false" do
        subject.write_to_cache(uncompleted_cache_hash)

        expect(subject.task_completed?).to eq(false)
      end

      context "when completed" do
        it "returns true" do
          subject.write_to_cache(completed_cache_hash)

          expect(subject.task_completed?).to eq(true)
        end
      end

      context "when nil" do
        it "returns true" do
          subject.write_to_cache(nil)

          expect(subject.task_completed?).to eq(false)
        end
      end
    end

    describe "#increment_resources_counter" do
      it "set the counter to the proper state" do
        subject.write_to_cache(uncompleted_cache_hash)

        subject.increment_resources_counter!

        expect(subject.read_from_cache).to eq(total: 2, current: 1)
      end
    end

    describe "#task_running??" do
      context "when cache entry is empty" do
        it "returns false" do
          subject.write_to_cache({})

          expect(subject.task_running?).to eq(false)
        end
      end

      context "when cache entry is unset" do
        it "returns false" do
          expect(subject.task_running?).to eq(false)
        end
      end

      context "when cache entry is nil" do
        it "returns false" do
          subject.write_to_cache(nil)

          expect(subject.task_running?).to eq(false)
        end
      end

      context "when pending" do
        it "returns false if task is running" do
          subject.write_to_cache(running_cache_hash)

          expect(subject.task_running?).to eq(true)
        end
      end
    end
  end
end
