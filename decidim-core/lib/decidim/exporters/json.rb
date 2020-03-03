# frozen_string_literal: true

require "json"

module Decidim
  module Exporters
    # Exports a JSON version of a provided hash, given a collection and a
    # Serializer.
    class JSON < Exporter
      # Public: Generates a JSON representation of a collection and a
      # Serializer.
      #
      # Returns an ExportData with the export.
      def export
        data = ::JSON.pretty_generate(@collection.map do |resource|
          @serializer.new(resource).serialize
        end)

        ExportData.new(data, "json")
      end

      # Public: Generates a JSON representation of a collection and a
      # Serializer.
      # It injects some informations as author's data which can only be exported by admin
      #
      # Returns an ExportData with the export.
      def admin_export
        data = ::JSON.pretty_generate(@collection.map do |resource|
          @serializer.new(resource, false).serialize
        end)

        ExportData.new(data, "json")
      end
    end
  end
end
