# frozen_string_literal: true

module Decidim
  module Verifications
    # Helper method related to initiative object and its internal state.
    module MetadataHelper
      include ActionView::Helpers::TagHelper
      include Decidim::SanitizeHelper

      def metadata_modal_button_to(authorization, html_options, &block)
        html_options ||= {}
        html_options["data-open"] = "authorizationModal"
        html_options["data-open-url"] = metadata_authorization_path(authorization)
        html_options["onclick"] = "event.preventDefault();"
        send("button_to", "", html_options, &block)
      end

      def table_from_data(data, level = 1)
        return unless data.is_a? Hash

        content_tag(:table, class: "metadata level-#{level}") do
          content_tag(:tbody) do
            tbody = ""
            data.each do |key, value|
              next if empty_metadata_value?(value)

              tbody += content_tag(:tr) do
                row = ""
                row += content_tag(:td, class: "key") do
                  render partial: "decidim/verifications/metadata/key", locals: { key: key, value: value }
                end
                row += content_tag(:td, class: "value") do
                  if value.is_a? Hash
                    table_from_data(value, level + 1)
                  else
                    render partial: "decidim/verifications/metadata/value", locals: { key: key, value: value }
                  end
                end
                row.html_safe
              end
            end
            tbody.html_safe
          end
        end
      end

      def empty_metadata_value?(value)
        if value.is_a? Hash
          value.empty? || value.values.all? { |v| empty_metadata_value?(v) }
        else
          value.blank?
        end
      end

      def humanize_handler_name(name)
        Rails.application.secrets.dig(:omniauth, name.to_sym, :provider_name).presence || name.to_s.humanize
      end
    end
  end
end
