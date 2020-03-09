# frozen_string_literal: true

module Decidim
  module Exporters
    # This is an abstract class with a very naive default implementation
    # for the exporters to use. It can also serve as a superclass of your
    # own implementation.
    #
    # It is used to be run against each element of an exportable collection
    # in order to extract relevant fields. Every export should specify their
    # own serializer or this default will be used.
    class Serializer
      attr_reader :resource

      # Initializes the serializer with a resource.
      #
      # resource - The Object to serialize.
      # private_scope - Boolean to differentiate open data export and administrator export. By default scope is public.
      def initialize(resource, private_scope = false)
        @resource = resource
        @private_scope = private_scope
      end

      # Public: Returns a serialized view of the provided resource.
      #
      # Returns a nested Hash with the fields.
      def serialize
        @resource.to_h.merge options_merge(admin_extra_fields)
      end

      private

      # Private: Returns a Hash with additional fields to export if the export is done by administrator
      #
      # Returns a empty hash or Hash with some other fields
      def options_merge(options = {})
        return {} unless options.is_a?(Hash) && @private_scope
        options
      end

      # Private: Returns a Hash with additional fields that administrator want to see in export
      #
      # Returns a Hash
      def admin_extra_fields
        {}
      end

      def translated_column_name(attribute, scope)
        I18n.t(attribute.to_sym, scope: scope)
      end
    end
  end
end
