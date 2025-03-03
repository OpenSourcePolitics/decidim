# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ai::SpamDetection::Strategy::ThirdParty do
  subject { described_class.new(options) }

  let(:options) { {} }
  let(:content) { "Content to analyze by third party service." }
  let(:api_response) { double(code: 200, body: res_body) }
  let(:res_body) do
    { "choices" => [{ "message" => { "content" => { "spam" => 0.95 } } }] }.to_json
  end

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
    before do
      allow(subject).to receive(:request).with(content).and_return(api_response) # rubocop:disable RSpec/SubjectStub
    end

    it "calls classify" do
      expect(subject.classify(content)).to eq(0.95)
    end
  end

  describe "log" do
    before do
      subject.instance_variable_set(:@score, 0.3)
    end

    it "returns a log" do
      expect(subject.log).to eq("AI system didn't marked this content as spam, see score: 0.3")
    end

    context "when content is spam" do
      before do
        subject.instance_variable_set(:@score, 0.3)
        allow(Decidim::Ai::SpamDetection).to receive(:resource_score_threshold).and_return(0.299)
      end

      it "returns a log" do
        expect(subject.log).to eq("AI system marked this as spam with a score of 0.3")
      end
    end
  end

  describe "score" do
    it "returns a score" do
      expect(subject).to respond_to(:score)
      expect(subject.score).to be_nil
    end
  end
end
