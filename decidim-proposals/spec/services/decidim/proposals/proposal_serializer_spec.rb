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
          expect(serialized).to include(id: proposal.id)
        end

        it "serializes the category" do
          expect(serialized[:category]).to include(id: category.id)
          expect(serialized[:category]).to include(name: category.name)
        end

        it "serializes the scope" do
          expect(serialized[:scope]).to include(id: scope.id)
          expect(serialized[:scope]).to include(name: scope.name)
        end

        it "serializes the title" do
          expect(serialized).to include(title: proposal.title)
        end

        it "serializes the body" do
          expect(serialized).to include(body: proposal.body)
        end

        it "serializes the amount of supports" do
          expect(serialized).to include(supports: proposal.proposal_votes_count)
        end

        it "serializes the amount of comments" do
          expect(serialized).to include(comments: proposal.comments.count)
        end

        it "serializes the date of creation" do
          expect(serialized).to include(published_at: proposal.published_at)
        end

        it "serializes the url" do
          expect(serialized[:url]).to include("http", proposal.id.to_s)
        end

        it "serializes the component" do
          expect(serialized[:component]).to include(id: proposal.component.id)
        end

        it "serializes the meetings" do
          expect(serialized[:meeting_urls].length).to eq(2)
          expect(serialized[:meeting_urls].first).to match(%r{http.*/meetings})
        end

        it "serializes the participatory space" do
          expect(serialized[:participatory_space]).to include(id: participatory_process.id)
          expect(serialized[:participatory_space][:url]).to include("http", participatory_process.slug)
        end

        it "serializes the state" do
          expect(serialized).to include(state: proposal.state)
        end

        it "serializes the reference" do
          expect(serialized).to include(reference: proposal.reference)
        end

        it "serializes the answer" do
          expect(serialized).to include(answer: expected_answer)
        end

        it "serializes the amount of attachments" do
          expect(serialized).to include(attachments: proposal.attachments.count)
        end

        it "serializes the amount of endorsements" do
          expect(serialized).to include(endorsements: proposal.endorsements.count)
        end

        it "serializes related proposals" do
          expect(serialized[:related_proposals].length).to eq(2)
          expect(serialized[:related_proposals].first).to match(%r{http.*/proposals})
        end

        it "doesn't serializes authors data" do
          expect(serialized).not_to include(:authors)
        end

        context "when export is made by administrator on backoffice" do
          subject do
            described_class.new(proposal, true)
          end

          let(:registration_metadata) { { birth_date: [], gender: [], work_area: [], residential_area: [], statutory_representative_email: [] } }

          it "serializes the authors" do
            expect(serialized).to include(:authors)
          end

          context "when creator is a unique user" do
            before do
              registration_metadata.each_pair { |k, _v| registration_metadata[k].clear }
              proposal.authors.collect(&:registration_metadata).each do |hash|
                hash.each_key do |k|
                  registration_metadata[k.to_sym] << if hash[k].is_a?(Hash)
                                                       hash[k].transform_keys(&:to_sym)
                                                     else
                                                       hash[k]
                                                     end
                end
              end
            end

            it "serializes author data" do
              expect(serialized[:authors]).to include(names: proposal.authors.first.try(:name))
              expect(serialized[:authors]).to include(nicknames: proposal.authors.first.try(:nickname))
              expect(serialized[:authors]).to include(emails: proposal.authors.first.try(:email))
              expect(serialized[:authors]).to include(gender: proposal.authors.first.try(:registration_metadata)[:gender.to_s])
              expect(serialized[:authors]).to include(work_area: proposal.authors.first.try(:registration_metadata)[:work_area.to_s])
              expect(serialized[:authors]).to include(residential_area: proposal.authors.first.try(:registration_metadata)[:residential_area.to_s])
              expect(serialized[:authors]).to include(statutory_representative_email: proposal.authors.first.try(:registration_metadata)[:statutory_representative_email.to_s])
              expect(serialized[:authors][:birth_date]).to eq(registration_metadata[:birth_date].join(","))
            end
            context "when unique user doesn't have registration metadata" do
              before do
                proposal.authors.first[:registration_metadata].clear
              end

              it "leaves empty each fields" do
                expect(serialized[:authors][:birth_date]).to be_empty
                expect(serialized[:authors][:gender]).to be_empty
                expect(serialized[:authors][:work_area]).to be_empty
                expect(serialized[:authors][:residential_area]).to be_empty
                expect(serialized[:authors][:statutory_representative_email]).to be_empty
              end
            end
          end

          context "when there is several creators" do
            let(:another_creator) { create(:user, :confirmed, organization: proposal.organization) }

            before do
              another_creator[:registration_metadata][:work_area] = "Lorem"
              another_creator[:registration_metadata][:residential_area] = "Lorem"
              registration_metadata.each_pair { |k, _v| registration_metadata[k].clear }
              proposal.add_coauthor(another_creator)
              proposal.authors.collect(&:registration_metadata).each do |hash|
                hash.each_key do |k|
                  registration_metadata[k.to_sym] << if hash[k].is_a?(Hash)
                                                       hash[k].transform_keys(&:to_sym)
                                                     else
                                                       hash[k]
                                                     end
                end
              end
            end

            it "serializes authors data" do
              expect(serialized[:authors]).to include(names: proposal.authors.collect(&:name).join(","))
              expect(serialized[:authors]).to include(nicknames: proposal.authors.collect(&:nickname).join(","))
              expect(serialized[:authors]).to include(emails: proposal.authors.collect(&:email).join(","))
              expect(serialized[:authors]).to include(gender: registration_metadata[:gender].join(","))
              expect(serialized[:authors]).to include(:work_area)
              expect(serialized[:authors]).to include(:residential_area)
              expect(serialized[:authors]).to include(statutory_representative_email: registration_metadata[:statutory_representative_email].join(","))
              expect(serialized[:authors][:birth_date]).to eq(registration_metadata[:birth_date].join(","))
            end

            it "serializes the two authors names" do
              expect(serialized[:authors][:names]).not_to be_empty
              expect(serialized[:authors][:names]).to include(proposal.authors.collect(&:name).join(","))
            end

            context "when a field is empty" do
              it "replaces empty value by dash" do
                expect(serialized[:authors][:work_area]).not_to eq(",Lorem")
                expect(serialized[:authors][:residential_area]).not_to eq(",Lorem")
                expect(serialized[:authors][:work_area]).to eq("-,Lorem")
                expect(serialized[:authors][:residential_area]).to eq("-,Lorem")
              end
            end
          end

          context "when creator is a user group" do
            let(:author) { create(:user, :confirmed, organization: proposal.organization) }
            let(:user_group) { create(:user_group, :verified, users: [author], organization: proposal.organization) }

            before do
              proposal.coauthorships.clear
              proposal.add_coauthor(author, user_group: user_group)
              registration_metadata.each_pair { |k, _v| registration_metadata[k].clear }
              proposal.authors.collect(&:registration_metadata).each do |hash|
                hash.each_key do |k|
                  registration_metadata[k.to_sym] << if hash[k].is_a?(Hash)
                                                       hash[k].transform_keys(&:to_sym)
                                                     else
                                                       hash[k]
                                                     end
                end
              end
            end

            it "serializes authors data" do
              expect(serialized[:authors]).to include(names: proposal.authors.collect(&:name).join(","))
              expect(serialized[:authors]).to include(nicknames: proposal.authors.collect(&:nickname).join(","))
              expect(serialized[:authors]).to include(emails: proposal.authors.collect(&:email).join(","))
              expect(serialized[:authors]).to include(gender: registration_metadata[:gender].join(","))
              expect(serialized[:authors]).to include(:work_area)
              expect(serialized[:authors]).to include(:residential_area)
              expect(serialized[:authors]).to include(statutory_representative_email: registration_metadata[:statutory_representative_email].join(","))
              expect(serialized[:authors][:birth_date]).to eq(registration_metadata[:birth_date].join(","))
            end
          end

          context "when creator is the organization" do
            before do
              proposal.coauthorships.clear
              proposal.add_coauthor(proposal.organization)
            end

            it "serializes authors metadata" do
              expect(serialized).to include(:authors)
              expect(serialized[:authors]).to include(:names)
              expect(serialized[:authors]).to include(:nicknames)
              expect(serialized[:authors]).to include(:emails)
              expect(serialized[:authors]).to include(:birth_date)
              expect(serialized[:authors]).to include(:gender)
              expect(serialized[:authors]).to include(:work_area)
              expect(serialized[:authors]).to include(:residential_area)
              expect(serialized[:authors]).to include(:statutory_representative_email)
            end

            it "leaves empty each values" do
              expect(serialized[:authors][:names]).to be_empty
              expect(serialized[:authors][:nicknames]).to be_empty
              expect(serialized[:authors][:emails]).to be_empty
              expect(serialized[:authors][:birth_date]).to be_empty
              expect(serialized[:authors][:gender]).to be_empty
              expect(serialized[:authors][:work_area]).to be_empty
              expect(serialized[:authors][:residential_area]).to be_empty
              expect(serialized[:authors][:statutory_representative_email]).to be_empty
            end
          end
        end

        context "with proposal having an answer" do
          let!(:proposal) { create(:proposal, :with_answer) }

          it "serializes the answer" do
            expect(serialized).to include(answer: expected_answer)
          end
        end
      end
    end
  end
end
