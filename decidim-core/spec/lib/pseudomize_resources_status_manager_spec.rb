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

    let(:component) { proposal_component }
    let(:proposal_component) { create(:proposal_component) }

    describe "#read_cache_entry" do
      it "returns the current state of the task" do
        subject.write(uncompleted_status)

        expect(subject.read).to eq(uncompleted_status)
      end
    end

    describe "#task_completed?" do
      it "returns false" do
        subject.write(uncompleted_status)

        expect(subject).not_to be_task_completed
      end

      context "when completed" do
        it "returns true" do
          subject.write(completed_status)

          expect(subject).to be_task_completed
        end
      end

      context "when nil" do
        it "returns false" do
          subject.write(nil)

          expect(subject).not_to be_task_completed
        end
      end
    end

    describe "#increment_resources_counter" do
      it "set the counter to the proper state" do
        subject.write(uncompleted_status)

        subject.increment_resources_counter!

        expect(subject.read).to eq(total: 2, current: 1)
      end

      context "when cache entry is nil" do
        before do
          subject.write(nil)
        end

        it "returns nil" do
          expect(subject.increment_resources_counter!).to be_nil
          expect(subject.read).to eq(nil)
        end
      end

      context "when cache entry doesn't contains 'current' key" do
        before do
          subject.write(total: 3)
        end

        it "returns nil" do
          expect(subject.increment_resources_counter!).to be_nil
          expect(subject.read).to eq(total: 3)
        end
      end
    end

    describe "#task_running?" do
      it "returns true" do
        subject.write(uncompleted_status)
        expect(subject).to be_task_running
      end

      context "when cache entry is empty" do
        it "returns false" do
          subject.write({})

          expect(subject).not_to be_task_running
        end
      end

      context "when cache entry is unset" do
        it "returns false" do
          expect(subject).not_to be_task_running
        end
      end

      context "when cache entry is nil" do
        it "returns false" do
          subject.write(nil)

          expect(subject).not_to be_task_running
        end
      end
    end
  end
end
