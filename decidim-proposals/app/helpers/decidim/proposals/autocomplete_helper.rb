# frozen_string_literal: true

module Decidim
  module Proposals
    # This helper include some methods for implementing here api auto completion.
    module AutocompleteHelper
      # Add a datalist and autocompletion script
      # datalist_id: String, must match the related text input 'list' attribute value
      def here_autocomplete(datalist_id = "here_suggestions")
        return if Decidim.geocoder.blank?
        return unless Decidim.geocoder[:enable_autocomplete]
        content = capture { yield }.html_safe
        content_tag(:datalist, "", data: { here_api: Decidim.geocoder.fetch(:here_api_key) }, id: datalist_id) + content
      end
    end
  end
end
