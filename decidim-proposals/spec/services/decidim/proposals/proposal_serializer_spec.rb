# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalSerializer do
      subject do
        described_class.new(proposal)
      end

      let!(:proposal) { create(:proposal, :accepted) }
      let!(:category) { create(:category, participatory_space: component.participatory_space) }
      let!(:scope) { create(:scope, organization: component.participatory_space.organization) }
      let(:participatory_process) { component.participatory_space }
      let(:component) { proposal.component }

      let!(:meetings_component) { create(:component, manifest_name: "meetings", participatory_space: participatory_process) }
      let(:meetings) { create_list(:meeting, 2, component: meetings_component) }

      let!(:proposals_component) { create(:component, manifest_name: "proposals", participatory_space: participatory_process) }
      let(:other_proposals) { create_list(:proposal, 2, component: proposals_component) }

      let(:expected_answer) do
        answer = proposal.answer
        Decidim.available_locales.each_with_object({}) do |locale, result|
          result[locale.to_s] = if answer.is_a?(Hash)
                                  answer[locale.to_s] || ""
                                else
                                  ""
                                end
        end
      end

      before do
        proposal.update!(category: category)
        proposal.update!(scope: scope)
        proposal.link_resources(meetings, "proposals_from_meeting")
        proposal.link_resources(other_proposals, "copied_from_component")
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(t("decidim.proposals.admin.exports.column_name.proposals.id") => proposal.id)
        end

        it "serializes the category" do
          expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.category.category")]).to include(t("decidim.proposals.admin.exports.column_name.proposals.category.id") => category.id)
          expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.category.category")]).to include(t("decidim.proposals.admin.exports.column_name.proposals.category.name") => category.name)
        end

        it "serializes the scope" do
          expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.scope.scope")]).to include(t("decidim.proposals.admin.exports.column_name.proposals.scope.id") => scope.id)
          expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.scope.scope")]).to include(t("decidim.proposals.admin.exports.column_name.proposals.scope.name") => scope.name)
        end

        it "serializes the title" do
          expect(serialized).to include(t("decidim.proposals.admin.exports.column_name.proposals.title") => proposal.title)
        end

        it "serializes the body" do
          expect(serialized).to include(t("decidim.proposals.admin.exports.column_name.proposals.body") => proposal.body)
        end

        it "serializes the amount of supports" do
          expect(serialized).to include(t("decidim.proposals.admin.exports.column_name.proposals.supports") => proposal.proposal_votes_count)
        end

        it "serializes the amount of comments" do
          expect(serialized).to include(t("decidim.proposals.admin.exports.column_name.proposals.comments") => proposal.comments.count)
        end

        it "serializes the date of creation" do
          expect(serialized).to include(t("decidim.proposals.admin.exports.column_name.proposals.published_at") => proposal.published_at)
        end

        it "serializes the url" do
          expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.url")]).to include("http", proposal.id.to_s)
        end

        it "serializes the component" do
          expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.component.component")]).to include(t("decidim.proposals.admin.exports.column_name.proposals.component.id") => proposal.component.id)
        end

        it "serializes the meetings" do
          expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.meeting_urls")].length).to eq(2)
          expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.meeting_urls")].first).to match(%r{http.*/meetings})
        end

        it "serializes the participatory space" do
          expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.participatory_space.participatory_space")]).to include(t("decidim.proposals.admin.exports.column_name.proposals.participatory_space.id") => participatory_process.id)
          expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.participatory_space.participatory_space")][t("decidim.proposals.admin.exports.column_name.proposals.participatory_space.url")]).to include("http", participatory_process.slug)
        end

        it "serializes the state" do
          expect(serialized).to include(t("decidim.proposals.admin.exports.column_name.proposals.state") => proposal.state)
        end

        it "serializes the reference" do
          expect(serialized).to include(t("decidim.proposals.admin.exports.column_name.proposals.reference") => proposal.reference)
        end

        it "serializes the answer" do
          expect(serialized).to include(t("decidim.proposals.admin.exports.column_name.proposals.answer") => expected_answer)
        end

        it "serializes the amount of attachments" do
          expect(serialized).to include(t("decidim.proposals.admin.exports.column_name.proposals.attachments") => proposal.attachments.count)
        end

        it "serializes the amount of endorsements" do
          expect(serialized).to include(t("decidim.proposals.admin.exports.column_name.proposals.endorsements") => proposal.endorsements.count)
        end

        it "serializes related proposals" do
          expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.related_proposals")].length).to eq(2)
          expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.related_proposals")].first).to match(%r{http.*/proposals})
        end

        it "doesn't serializes authors data" do
          expect(serialized).not_to include(t("decidim.proposals.admin.exports.column_name.proposals.authors.authors"))
        end

        context "when export is made by administrator on backoffice" do
          subject do
            described_class.new(proposal, true)
          end

          it "serializes authors" do
            expect(serialized).to include(t("decidim.proposals.admin.exports.column_name.proposals.authors.authors"))
          end

          context "when creator is a unique user" do
            it "serializes author data" do
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")]).to include(t("decidim.proposals.admin.exports.column_name.proposals.authors.names") => proposal.authors.collect(&:name).join(","))
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")]).to include(t("decidim.proposals.admin.exports.column_name.proposals.authors.nicknames") => proposal.authors.collect(&:nickname).join(","))
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")]).to include(t("decidim.proposals.admin.exports.column_name.proposals.authors.emails") => proposal.authors.collect(&:email).join(","))
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")]).to include( t("decidim.proposals.admin.exports.column_name.proposals.authors.authors_registration_metadata") => proposal.authors.collect(&:registration_metadata))
            end
          end

          context "when there is several creators" do
            let(:another_creator) { create(:user, :confirmed, organization: proposal.organization) }

            before do
              proposal.add_coauthor(another_creator)
            end

            it "serializes authors data" do
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")]).to include(t("decidim.proposals.admin.exports.column_name.proposals.authors.names") => proposal.authors.collect(&:name).join(","))
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")]).to include(t("decidim.proposals.admin.exports.column_name.proposals.authors.nicknames") => proposal.authors.collect(&:nickname).join(","))
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")]).to include(t("decidim.proposals.admin.exports.column_name.proposals.authors.emails") => proposal.authors.collect(&:email).join(","))
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")]).to include( t("decidim.proposals.admin.exports.column_name.proposals.authors.authors_registration_metadata") => proposal.authors.collect(&:registration_metadata))
            end

            it "serializes the two authors names" do
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")][t("decidim.proposals.admin.exports.column_name.proposals.authors.names")]).not_to be_empty
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")][t("decidim.proposals.admin.exports.column_name.proposals.authors.names")]).to include(proposal.authors.collect(&:name).join(","))
            end
          end

          context "when creator is a user group" do
            let(:author) { create(:user, :confirmed, organization: proposal.organization) }
            let(:user_group) { create(:user_group, :verified, users: [author], organization: proposal.organization) }

            before do
              proposal.coauthorships.clear
              proposal.add_coauthor(author, user_group: user_group)
            end

            it "serializes authors data" do
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")]).to include(t("decidim.proposals.admin.exports.column_name.proposals.authors.names") => proposal.authors.collect(&:name).join(","))
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")]).to include(t("decidim.proposals.admin.exports.column_name.proposals.authors.nicknames") => proposal.authors.collect(&:nickname).join(","))
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")]).to include(t("decidim.proposals.admin.exports.column_name.proposals.authors.emails") => proposal.authors.collect(&:email).join(","))
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")]).to include( t("decidim.proposals.admin.exports.column_name.proposals.authors.authors_registration_metadata") => proposal.authors.collect(&:registration_metadata))
            end
          end

          context "when creator is the organization" do
            before do
              proposal.coauthorships.clear
              proposal.add_coauthor(proposal.organization)
            end

            it "serializes authors metadata" do
              expect(serialized).to include(t("decidim.proposals.admin.exports.column_name.proposals.authors.authors"))
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")]).to include(t("decidim.proposals.admin.exports.column_name.proposals.authors.names"))
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")]).to include(t("decidim.proposals.admin.exports.column_name.proposals.authors.nicknames"))
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")]).to include(t("decidim.proposals.admin.exports.column_name.proposals.authors.emails"))
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")]).to include(t("decidim.proposals.admin.exports.column_name.proposals.authors.authors_registration_metadata"))
            end

            it "leaves empty each values" do
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")][t("decidim.proposals.admin.exports.column_name.proposals.authors.names")]).to be_empty
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")][t("decidim.proposals.admin.exports.column_name.proposals.authors.nicknames")]).to be_empty
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")][t("decidim.proposals.admin.exports.column_name.proposals.authors.emails")]).to be_empty
              expect(serialized[t("decidim.proposals.admin.exports.column_name.proposals.authors.authors")][t("decidim.proposals.admin.exports.column_name.proposals.authors.authors_registration_metadata")]).to be_empty
            end
          end
        end

        context "with proposal having an answer" do
          let!(:proposal) { create(:proposal, :with_answer) }

          it "serializes the answer" do
            expect(serialized).to include(t("decidim.proposals.admin.exports.column_name.proposals.answer") => expected_answer)
          end
        end
      end
    end
  end
end
