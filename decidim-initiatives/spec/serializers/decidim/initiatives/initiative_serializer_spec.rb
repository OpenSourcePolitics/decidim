# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativeSerializer do
      subject do
        described_class.new(initiative)
      end

      let!(:initiative) { create(:initiative, organization: organization) }
      let(:organization) { create(:organization) }

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(id: initiative.id)
        end

        it "serializes the reference" do
          expect(serialized).to include(reference: initiative.reference)
        end

        it "serializes the title" do
          expect(serialized).to include(title: initiative.title)
        end

        it "serializes the description" do
          expect(serialized).to include(description: initiative.description)
        end

        it "serializes the created_at" do
          expect(serialized).to include(created_at: initiative.created_at)
        end

        it "serializes the published_at" do
          expect(serialized).to include(published_at: initiative.published_at)
        end

        it "serializes the hashtag" do
          expect(serialized).to include(hashtag: initiative.hashtag)
        end

        it "serializes the type" do
          expect(serialized[:type]).to be_a_kind_of Hash
          expect(serialized[:type]).to include(id: initiative.type.id)
          expect(serialized[:type]).to include(name: initiative.type.title)
        end

        it "serializes the scope" do
          expect(serialized[:scope]).to be_a_kind_of Hash
          expect(serialized[:scope]).to include(id: initiative.scope.id)
          expect(serialized[:scope]).to include(name: initiative.scope.name)
        end

        it "serializes the signature_type" do
          expect(serialized).to include(signature_type: initiative.signature_type)
        end

        it "serializes the signature_start_date" do
          expect(serialized).to include(signature_start_date: initiative.signature_start_date)
        end

        it "serializes the signature_end_date" do
          expect(serialized).to include(signature_end_date: initiative.signature_end_date)
        end

        it "serializes the state" do
          expect(serialized).to include(state: initiative.state)
        end

        it "serializes the offline_votes" do
          expect(serialized).to include(offline_votes: initiative.offline_votes)
        end

        it "serializes the answer" do
          expect(serialized).to include(answer: initiative.answer)
        end

        it "serializes attachments, components, authors" do
          expect(serialized).to have_key(:attachments)
          expect(serialized).to have_key(:components)
          expect(serialized).to have_key(:authors)
        end

        it "serializes the scopes vote count" do
          expect(serialized[:firms]).to be_a_kind_of Hash
          expect(serialized[:firms]).to include(scopes: 0)
        end

        context "when there is votes" do
          let(:vote) { create_list(:initiative_user_vote, 5, initiative: initiative) }

          it "serializes uniq scopes vote count" do
            expect(serialized[:firms]).to be_a_kind_of Hash
            expect(serialized[:firms]).to include(scopes: initiative.votes.map(&:decidim_scope_id).uniq.size)
          end
        end
      end
    end
  end
end
