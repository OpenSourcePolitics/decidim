# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ai::SpamDetection::Strategy::ThirdParty do
  subject { described_class.new(options) }

  let(:options) { {} }

  describe "train" do
    it "returns nothing" do
      expect(subject.train(:spam, "text")).to be_nil
    end
  end

  describe "untrain" do
    it "returns nothing" do
      expect(subject.untrain(:spam, "text")).to be_nil
    end
  end

  describe "classify" do
    it "calls backend.classify" do
      expect(subject.classify("Here is my content sent")).to eq(0.95)
    end
  end

  describe "log" do
    it "returns a log" do
      expect(subject.log).to eq("AI system didn't marked this content as spam, see score: 0.3")
    end

    context "when content is spam" do
      it "returns a log" do
        expect(subject.log).to eq("AI system marked this as spam with a score of 0.95")
      end
    end
  end

  describe "score" do
    it "returns a score" do
      expect(subject.score).to eq(0)
    end

    it "returns AI system's score" do
      expect(subject.score).to eq(0.95)
    end
  end
end
