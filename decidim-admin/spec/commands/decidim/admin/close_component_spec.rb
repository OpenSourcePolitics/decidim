# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CloseComponent do
    subject { described_class.new(component) }

    let(:component) { proposal_component }
    let(:proposal_component) { create(:proposal_component) }
    let!(:proposal) { create(:proposal, component: component) }
    let!(:comment) { create(:comment, commentable: proposal) }

    describe "#call" do
      it "enqueues the jobs" do
        expect { subject.call }.to have_enqueued_job(Decidim::PseudomizeResourceAuthorsJob).exactly(:twice)
      end
    end

    describe "#resources" do
      it "returns resources" do
        expect(subject.send(:resources)).to match_array([comment, proposal])
      end
    end

    describe "#resources_for_component" do
      it "returns resources_for_component" do
        expect(subject.send(:resources_for_component)).to match_array([proposal])
      end
    end

    describe "#comments_for" do
      it "returns comments_for" do
        expect(subject.send(:comments_for, proposal)).to match_array([comment])
      end
    end

    describe "#resources_classes" do
      it "returns resources_classes" do
        expect(subject.send(:resources_classes)).to match_array([
                                                                  "Decidim::DummyResources::DummyResource",
                                                                  "Decidim::Pages::Page",
                                                                  "Decidim::Meetings::Meeting",
                                                                  "Decidim::Proposals::Proposal",
                                                                  "Decidim::Proposals::CollaborativeDraft",
                                                                  "Decidim::Budgets::Project",
                                                                  "Decidim::Accountability::Result",
                                                                  "Decidim::Debates::Debate",
                                                                  "Decidim::Sortitions::Sortition",
                                                                  "Decidim::Blogs::Post"
                                                                ])
      end
    end
  end
end
