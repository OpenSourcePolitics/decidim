# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Initiatives
    # Common logic to ordering resources
    module Orderable
      extend ActiveSupport::Concern

      included do
        include Decidim::Orderable

        # Available orders based on enabled settings
        def available_orders
          @available_orders ||= begin
            %w(random recent most_voted recently_published answer_date)
          end
        end

        def default_order
          "random"
        end

        def reorder(initiatives)
          case order
          when "most_voted"
            initiatives.order_by_supports
          when "most_commented"
            initiatives.order_by_most_commented
          when "recent"
            initiatives.order_by_most_recent
          when "recently_published"
            initiatives.order_by_most_recently_published
          when "answer_date"
            initiatives.order_by_answer_date
          else
            initiatives.order_randomly(random_seed)
          end
        end
      end
    end
  end
end
