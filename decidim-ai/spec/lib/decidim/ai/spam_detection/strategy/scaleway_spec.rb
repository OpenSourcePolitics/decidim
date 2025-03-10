# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::Ai::SpamDetection::Strategy::Scaleway do
  subject { described_class.new(options) }

  let(:endpoint) { "https://example.com/api" }
  let(:secret) { "secret_key" }
  let(:options) do
    {
      endpoint: endpoint,
      secret: secret,
      model: "model_name",
      system_message: "System message",
      max_tokens: 100,
      temperature: 0.7,
      top_p: 0.9,
      presence_penalty: 0,
      stream: false
    }
  end

  describe "#third_party_content" do
    context "when body contains valid JSON with choices" do
      let(:body) do
        {
          "choices" => [
            {
              "message" => {
                "content" => "SPAM"
              }
            }
          ]
        }.to_json
      end

      it "returns the content of the first choice" do
        expect(subject.third_party_content(body)).to eq("SPAM")
      end
    end

    context "when body contains valid JSON without choices" do
      let(:body) do
        {
          "choices" => []
        }.to_json
      end

      it "returns nil" do
        expect(subject.third_party_content(body)).to be_nil
      end
    end

    context "when body contains invalid JSON" do
      let(:body) { "invalid json" }

      it "raises a JSON::ParserError" do
        expect { subject.third_party_content(body) }.to raise_error(JSON::ParserError)
      end
    end

    context "when body is empty" do
      let(:body) { "" }

      it "returns nil" do
        expect(subject.third_party_content(body)).to be_empty
      end
    end
  end

  describe "#classify" do
    let(:response_double) { double("Net::HTTPResponse", body: '{"choices": [{"message": {"content": "NOT_SPAM"}}]}', is_a?: true) }

    before do
      allow(subject).to receive(:request).and_return(response_double)
    end

    it "classifies content as not spam" do
      expect(subject.classify("Test content")).to eq(0)
    end

    context "when response is invalid" do
      before do
        allow(response_double).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)
        allow(response_double).to receive(:error).and_return("Error message")
      end

      it "raises InvalidEntity error" do
        expect { subject.classify("Test content") }.to raise_error(Decidim::Ai::SpamDetection::Strategy::ThirdParty::InvalidEntity)
      end
    end

    context "when response format is invalid" do
      before { allow(subject).to receive(:valid_output_format?).and_return(false) }

      it "raises InvalidOutputFormat error" do
        expect { subject.classify("Test content") }.to raise_error(Decidim::Ai::SpamDetection::Strategy::ThirdParty::InvalidOutputFormat)
      end
    end
  end
end
