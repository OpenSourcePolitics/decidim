# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Strategy
        class ThirdParty < Base
          class InvalidOutputFormat < StandardError; end

          class InvalidResponse < StandardError; end

          class InvalidEntity < StandardError; end

          OUTPUT = %w(SPAM NOT_SPAM).freeze
          def initialize(options = {})
            super
            @endpoint = options[:endpoint]
            @secret = options[:secret]
            @options = options
          end

          def log
            return "AI system didn't marked this content as spam, see score: #{score}" if score <= score_threshold

            "AI system marked this as spam"
          end

          def classify(content)
            system_log("(ThirdParty)> Starting classification...")
            res = request(content)
            body = res.body

            system_log("(ThirdParty)> Received response from third party service: #{body}")
            raise InvalidEntity, res.error unless res.is_a?(Net::HTTPSuccess)

            content = third_party_content(body)
            raise InvalidOutputFormat, "Third party service response isn't valid JSON" unless valid_output_format?(content)

            @category = content.downcase
            system_log("(ThirdParty)> Spam probability: #{score}")
            score
          end

          def request(content)
            uri = URI(@endpoint)
            payload = payload(content).to_json
            system_log("(ThirdParty)> Sending request to third party service: #{payload}")
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.post(uri.path, payload, headers)
          end

          def headers
            @headers ||= {
              "Authorization" => "Bearer #{@secret}",
              "Content-Type" => "application/json",
              "Accept" => "application/json"
            }
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

          def third_party_content(body) end

          def handle_service_response(res) end

          def score
            @score ||= @category.presence == "spam" ? 1 : 0
          end

          private

          attr_reader :options

          def valid_output_format?(output)
            output.present? && output.is_a?(String) && output.in?(OUTPUT)
          end

          def score_threshold
            return Decidim::Ai::SpamDetection.user_score_threshold if name == :third_party_user

            Decidim::Ai::SpamDetection.resource_score_threshold
          end

          def system_log(message, level: :info)
            Rails.logger.send(level, "[decidim-ai] #{self.class.name} - #{message}")
          end
        end
      end
    end
  end
end
