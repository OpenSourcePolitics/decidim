# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Strategy
        class Base
          attr_reader :name

          def initialize(options = {})
            @name = options.delete(:name)
            @options = options
          end

          def classify(_content); end

          def train(_classification, _content); end

          def untrain(_classification, _content); end

          def log; end

          def score = 0.0

          private

          def system_log(message, level: :info)
            Rails.logger.send(level, message)
          end
        end
      end
    end
  end
end
