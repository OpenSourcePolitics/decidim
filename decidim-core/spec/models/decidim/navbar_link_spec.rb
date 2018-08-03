# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NavbarLink do
    subject { navbar_link }

    let(:organization) { build(:organization) }
    let(:navbar_link) { build(:navbar_link, organization: organization) }

    it "has an association for organisation" do
      expect(subject.organization).to eq(organization)
    end

    describe "validations" do
      it "is valid" do
        expect(subject).to be_valid
      end

      it "is not valid without an organisation" do
        subject.organization = nil
        expect(subject).not_to be_valid
      end

      describe "#validate_link_regex" do
        it "should be false if link is correct" do
          uri = URI.parse(subject.link)
          expect(uri.host.nil?).to be_falsey
        end

        it "saves if link is incorrect" do
          subject.link = "@foo"
          expect(subject.save).not_to change(Decidim::NavbarLink.count)
        end

        it "adds an error" do
          subject.link = "@foo"
          expect(subject.save).to change(subject.errors[:link]).by(1)
        end

        it "adds an error with specific message" do
          subject.link = "@foo"
          subject.save
          expect(subject.errors[:link]).to include("is invalid")
        end
      end
    end
  end
end
