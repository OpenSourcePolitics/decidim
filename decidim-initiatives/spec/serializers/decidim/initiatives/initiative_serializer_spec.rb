# frozen_string_literal: true

require "spec_helper"

module Decidim::Initiatives
  describe InitiativeSerializer do
    subject { described_class.new(initiative) }

    let(:organization) { create(:organization) }
    let!(:initiative) { create(:initiative, :with_area, organization: organization) }
    let(:serialized) { subject.serialize }

    describe "#serialize" do
      it "includes the id" do
        expect(serialized).to include(id: initiative.id)
      end

      it "includes the title" do
        expect(serialized).to include(title: initiative.title)
      end

      it "includes the description" do
        expect(serialized).to include(description: initiative.description)
      end

      it "includes the state" do
        expect(serialized).to include(state: initiative.state)
      end

      it "includes the created_at timestamp" do
        expect(serialized).to include(created_at: initiative.created_at)
      end

      it "includes the published_at timestamp" do
        expect(serialized).to include(published_at: initiative.published_at)
      end

      it "serializes the reference" do
        expect(serialized).to include(reference: initiative.reference)
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

      it "serializes the signature_start_date" do
        expect(serialized).to include(signature_start_date: initiative.signature_start_date)
      end

      it "includes the signature_end_date" do
        expect(serialized).to include(signature_end_date: initiative.signature_end_date)
      end

      it "includes the signature_type" do
        expect(serialized).to include(signature_type: initiative.signature_type)
      end

      it "includes the number of signatures (supports)" do
        expect(serialized).to include(signatures: initiative.supports_count)
      end

      it "includes the authors' ids" do
        expect(serialized[:authors]).to include(id: initiative.author_users.map(&:id))
      end

      it "includes the authors' names" do
        expect(serialized[:authors]).to include(name: initiative.author_users.map(&:name))
      end

      it "includes the area name" do
        expect(serialized[:area]).to include(name: initiative.area.name)
      end

      it "serializes the offline_votes" do
        expect(serialized).to include(offline_votes: initiative.offline_votes)
      end

      it "serializes the answer" do
        expect(serialized).to include(answer: initiative.answer)
      end

      it "serializes attachments, components" do
        expect(serialized).to have_key(:attachments)
        expect(serialized).to have_key(:components)
      end

      it "serializes the scopes vote count" do
        expect(serialized[:firms]).to be_a_kind_of Hash
        expect(serialized[:firms]).to include(scopes: 0)
      end

      context "when there is votes" do
        let(:scopes) { create_list(:scope, 5, organization: organization) }
        let(:initiative) { create(:initiative, :with_user_extra_fields_collection, organization: organization) }

        before do
          create_list(:initiative_user_vote, 2, initiative: initiative,
                                                encrypted_metadata: Decidim::Initiatives::DataEncryptor.new(secret: "personal user metadata").encrypt(user_scope_id: scopes[2].id))

          create_list(:initiative_user_vote, 2, initiative: initiative,
                                                encrypted_metadata: Decidim::Initiatives::DataEncryptor.new(secret: "personal user metadata").encrypt(user_scope_id: scopes[3].id))

          create(:initiative_user_vote,
                 initiative: initiative,
                 encrypted_metadata: Decidim::Initiatives::DataEncryptor.new(secret: "personal user metadata").encrypt(user_scope_id: scopes.first.id))
        end

        it "serializes uniq scopes vote count" do
          expect(serialized[:firms]).to be_a_kind_of Hash
          expect(serialized[:firms]).to include(scopes: 3)
        end
      end
    end
  end
end
