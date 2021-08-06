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
    let!(:debate) { create(:debate, author: authors.last, component: debate_component) }
    let!(:comment_2) { create(:comment, author: authors.last, commentable: proposal) }

    describe "perform" do
      context "when respond to authors" do
        it "pseudomizes resource author" do
          subject.perform_now(proposal)

          expect(proposal.authors).not_to match_array(authors)
          authors.map do |author|
            expect(proposal.authors).not_to include(author)
          end
        end

        it "sends an email to authors" do
          allow(Decidim::Admin::PseudomizeMailer).to receive(:notfiy_user).and_call_original

          subject.perform_now(comment_1)

          expect(Decidim::Admin::PseudomizeMailer)
            .to have_received(:notfiy_admin)
            .with(authors.first).exactly(5)
        end

        it "sets confirmed_at" do
          subject.perform_now(proposal)

          expect(proposal.authors.map(&:confirmed_at)).not_to include(nil)
        end
      end

      context "when respond to author" do
        it "send an email to author" do
          allow(Decidim::Admin::PseudomizeMailer).to receive(:notfiy_user).and_call_original

          subject.perform_now(comment_1)

          expect(Decidim::Admin::PseudomizeMailer)
            .to have_received(:notfiy_admin)
            .with(authors.first)
        end

        it "pseudomizes resource author" do
          subject.perform_now(comment_1)

          expect(comment_1.author).not_to eq(authors.first)
        end
      end

      context "when author is already pseudomized" do
        let(:authors) { create_list(:user, 5, shadow: true, organization: organization) }

        it "reuses pseudomized author" do
          debate_author = authors.last

          expect do
            subject.perform_now(debate)

            expect(debate.author).to eq(debate_author)
          end.not_to change(Decidim::User, :count)
        end
      end

      context "when author already exist" do
        it "reuses author" do
          subject.perform_now(debate)
          debate_author = debate.author
          subject.perform_now(comment_2)

          expect(comment_2.author).to eq(debate_author)
        end
      end

      context "when author is an organization" do
        let!(:debate) { create(:debate, author: organization, component: debate_component) }

        it "reuses author" do
          subject.perform_now(debate)

          expect(debate.author).to eq(organization)
        end
      end
    end
  end
end
