# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Strategy
        class ThirdParty < Base
          class InvalidOutputFormat < StandardError; end

          class InvalidResponse < StandardError; end

          def initialize(options = {})
            super
            @endpoint = options[:endpoint]
            @secret = options[:secret]
            @options = options
          end

          def log
            return "AI system didn't marked this content as spam, see score failed" if score&.nil?
            return "AI system didn't marked this content as spam, see score: #{score}" if score.nan? || score <= score_threshold

            "AI system marked this as spam with a score of #{score}"
          end

          def classify(content)
            res = request(content)
            raise InvalidResponse unless res&.code&.to_i == 200

            body = res.body

            choices = JSON.parse(body)["choices"] || []
            content = choices.first.dig("message", "content")
            raise InvalidOutputFormat, "Third party service response isn't valid JSON" unless valid_output_format?(content)

            spam_probability = content["spam"]
            @score = spam_probability
            spam_probability
          rescue StandardError, InvalidOutputFormat, InvalidResponse => e
            Rails.logger.error(e)
          end

          attr_reader :score

          def valid_output_format?(output)
            output.presence && output.is_a?(Hash) && output.has_key?("spam")
          end

          def request(content)
            uri = URI(@endpoint)
            headers = {
              "Authorization" => "Bearer #{@secret}",
              "Content-Type" => "application/json",
              "Accept" => "application/json"
            }
            payload = payload(content).to_json

            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.post(uri.path, payload, headers)
          end

          def payload(content)
            {
              model: @options[:model],
              messages: [
                {
                  role: "system",
                  content: @options[:system_message]
                },
                {
                  role: "user",
                  content: content
                }
              ],
              max_tokens: @options[:max_tokens],
              temperature: @options[:temperature],
              top_p: @options[:top_p],
              presence_penalty: @options[:presence_penalty],
              stream: @options[:stream]
            }
          end

          private

          attr_reader :options

          def score_threshold
            return Decidim::Ai::SpamDetection.user_score_threshold if name == :third_party_user

            Decidim::Ai::SpamDetection.resource_score_threshold
          end
        end
      end
    end
  end
end
