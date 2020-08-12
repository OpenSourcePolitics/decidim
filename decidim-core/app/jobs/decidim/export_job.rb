# frozen_string_literal: true

module Decidim
  class ExportJob < ApplicationJob
    queue_as :default

    def perform(user, component, name, format)
      export_manifest = component.manifest.export_manifests.find do |manifest|
        manifest.name == name.to_sym
      end

      collection = if export_manifest.manifest.name == :proposals
                     export_manifest.collection.call(component).not_hidden
                   else
                     export_manifest.collection.call(component)
                   end

      serializer = export_manifest.serializer

      export_data = if serializer == Decidim::Proposals::ProposalSerializer
                      Decidim::Exporters.find_exporter(format).new(collection, serializer).admin_export
                    else
                      Decidim::Exporters.find_exporter(format).new(collection, serializer).export
                    end

      ExportMailer.export(user, name, export_data).deliver_now
    end
  end
end
