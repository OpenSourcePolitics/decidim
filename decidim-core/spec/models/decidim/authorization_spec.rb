# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Authorization do
    let(:authorization) { build(:authorization) }

    it "is valid" do
      expect(authorization).to be_valid
    end

    context "with metadata" do
      let(:authorization) { build(:authorization, metadata: { key_1: "First value", key_2: "Second value" }) }

      it "encrypts metadata and stringify keys" do
        expect(authorization.metadata).to eq("key_1" => "First value", "key_2" => "Second value")
      end
    end

    context "when leaving verification data around" do
      let(:authorization) do
        build(:authorization, verification_metadata: { sensible_stuff: "123456" })
      end

      it "is not valid" do
        expect(authorization).not_to be_valid
      end
    end
  end
end
