# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe PseudomizeResourceAuthorsJob do
    subject { described_class }

    let(:organization) { create(:organization) }
    let(:proposal_component) { create(:proposal_component, organization: organization) }
    let(:authors) { create_list(:user, 5, organization: organization) }
    let!(:proposal) { create(:proposal, users: authors, component: proposal_component) }
    let!(:comment_1) { create(:comment, author: authors.first, commentable: proposal) }
    let!(:debate_component) { create(:debates_component, organization: organization) }
    let(:debate_component_status) { Decidim::PseudomizeResourcesStatusManager.new(debate.component) }
    let(:comment_1_component_status) { Decidim::PseudomizeResourcesStatusManager.new(comment_1.component) }
    let(:proposal_component_status) { Decidim::PseudomizeResourcesStatusManager.new(proposal.component) }
    let!(:debate) { create(:debate, author: authors.last, component: debate_component) }
    let!(:comment_2) { create(:comment, author: authors.last, commentable: proposal) }
    let(:uncompleted_status) do
      { total: 2, current: 0 }
    end

    after do
      Rails.cache.clear
    end

    describe "perform" do
      context "when respond to authors" do
        it "pseudomizes resource author" do
          proposal_component_status.write(uncompleted_status)
          subject.perform_now(proposal, proposal.component)

          expect(proposal.authors).not_to match_array(authors)
          authors.map do |author|
            expect(proposal.authors).not_to include(author)
          end
        end

        it "sends an email to authors" do
          allow(Decidim::Admin::PseudomizeMailer).to receive(:notfiy_user).and_call_original
          comment_1_component_status.write(uncompleted_status)

          subject.perform_now(comment_1, comment_1.component)

          expect(Decidim::Admin::PseudomizeMailer)
            .to have_received(:notfiy_user)
            .exactly(5)
        end

        it "sets confirmed_at" do
          proposal_component_status.write(uncompleted_status)
          subject.perform_now(proposal, proposal.component)

          expect(proposal.authors.map(&:confirmed_at)).not_to include(nil)
        end
      end

      context "when respond to author" do
        it "send an email to author" do
          allow(Decidim::Admin::PseudomizeMailer).to receive(:notfiy_user).and_call_original

          comment_1_component_status.write(uncompleted_status)
          subject.perform_now(comment_1, comment_1.component)

          expect(Decidim::Admin::PseudomizeMailer)
            .to have_received(:notfiy_user)
            .with(authors.first)
        end

        it "pseudomizes resource author" do
          comment_1_component_status.write(uncompleted_status)
          subject.perform_now(comment_1, comment_1.component)

          expect(comment_1.author).not_to eq(authors.first)
        end
      end

      context "when author is already pseudomized" do
        let(:authors) { create_list(:user, 5, shadow: true, organization: organization) }

        it "reuses pseudomized author" do
          debate_author = authors.last

          expect do
            debate_component_status.write(uncompleted_status)
            subject.perform_now(debate, debate.component)

            expect(debate.author).to eq(debate_author)
          end.not_to change(Decidim::User, :count)
        end
      end

      context "when author already exist" do
        it "reuses author" do
          debate_component_status.write(uncompleted_status)
          comment_1_component_status.write(uncompleted_status)
          subject.perform_now(debate, debate.component)
          debate_author = debate.author
          subject.perform_now(comment_2, comment_1.component)

          expect(comment_2.author).to eq(debate_author)
        end
      end

      context "when author is an organization" do
        let!(:debate) { create(:debate, author: organization, component: debate_component) }

        it "reuses author" do
          debate_component_status.write(uncompleted_status)
          subject.perform_now(debate, debate.component)

          expect(debate.author).to eq(organization)
        end
      end
    end
  end
end
