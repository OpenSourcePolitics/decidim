# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Strategy
        class Scaleway < ThirdParty
          def third_party_content(body)
            return [] if body.blank?

            choices = JSON.parse(body)&.fetch("choices", [])
            choices.first&.dig("message", "content")
          end
        end
      end
    end
  end
end
