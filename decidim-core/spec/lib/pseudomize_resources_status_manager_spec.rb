# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe PseudomizeResourcesStatusManager do
    subject { described_class.new(component) }

    let(:uncompleted_status) do
      { total: 2, current: 0 }
    end
    let(:completed_status) do
      { total: 2, current: 2 }
    end

    let(:running_status) do
      { pending: true }
    end

    let(:component) { proposal_component }
    let(:proposal_component) { create(:proposal_component) }

    after do
      subject.erase_entry!
    end

    describe "#read_cache_entry" do
      it "returns the current state of the task" do
        subject.write(uncompleted_status)

        expect(subject.read).to eq(uncompleted_status)
      end
    end

    describe "#erase_cache_entry" do
      it "removes cache entry" do
        subject.erase_entry!

        expect(subject.read).to eq({})
      end
    end

    describe "#task_completed?" do
      it "returns false" do
        subject.write(uncompleted_status)

        expect(subject.task_completed?).to eq(false)
      end

      context "when completed" do
        it "returns true" do
          subject.write(completed_status)

          expect(subject.task_completed?).to eq(true)
        end
      end

      context "when nil" do
        it "returns true" do
          subject.write(nil)

          expect(subject.task_completed?).to eq(false)
        end
      end
    end

    describe "#increment_resources_counter" do
      it "set the counter to the proper state" do
        subject.write(uncompleted_status)

        subject.increment_resources_counter!

        expect(subject.read).to eq(total: 2, current: 1)
      end
    end

    describe "#task_running??" do
      context "when cache entry is empty" do
        it "returns false" do
          subject.write({})

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
          subject.write(nil)

          expect(subject.task_running?).to eq(false)
        end
      end

      context "when pending" do
        it "returns false if task is running" do
          subject.write(running_status)

          expect(subject.task_running?).to eq(true)
        end
      end
    end
  end
end
