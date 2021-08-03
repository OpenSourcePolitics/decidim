# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserPseudomizer do
    subject { described_class }

    let(:organization) { create(:organization) }
    let(:user) { build(:user, organization: organization) }

    describe "#hash" do
      context "when there is two different user" do
        let(:other_user) { build(:user, organization: organization) }

        it "generates different hashes" do
          expect(subject.pseudomize(user).hash).not_to eq(subject.pseudomize(other_user).hash)
        end
      end

      context "when attribute changes" do
        it "generates different hashes" do
          old_hash = subject.pseudomize(user).hash

          user.name = "new name"

          expect(subject.pseudomize(user).hash).not_to eq(old_hash)
        end
      end

      describe "#nickname" do
        let(:hash) { subject.pseudomize(user).hash }

        it "generates a hashed nickname" do
          expect(subject.pseudomize(user).nickname).to eq("Anonyme_#{hash}")
        end
      end

      describe "#name" do
        let(:hash) { subject.pseudomize(user).hash }

        it "generates a hashed name" do
          expect(subject.pseudomize(user).name).to eq("Anonyme_#{hash}")
        end
      end

      describe "#email" do
        let(:hash) { subject.pseudomize(user).hash }

        it "generates a hashed email" do
          expect(subject.pseudomize(user).email).to eq("#{hash}@anonyme.org")
        end
      end

      describe "#about" do
        let(:hash) { subject.pseudomize(user).hash }

        it "generates a hashed about" do
          expect(subject.pseudomize(user).about).to eq(hash.to_s)
        end
      end

      describe "#personal_url" do
        let(:hash) { subject.pseudomize(user).hash }

        it "generates a hashed personal_url" do
          expect(subject.pseudomize(user).personal_url).to eq(hash.to_s)
        end
      end
    end
  end
end
