# frozen_string_literal: true

module Decidim
  module System
    # Custom helpers, scoped to the system panel.
    #
    module LogsHelper
      def line_helper(lines_requested)
        "active" if lines_requested == lines
      end

      def auto_refresh_helper
        "active" if auto_refresh?
      end

      def search_input_helper
        "active" if search_input.present?
      end

      def search_reset_helper
        "hidden" if search_input.blank?
      end
    end
  end
end
