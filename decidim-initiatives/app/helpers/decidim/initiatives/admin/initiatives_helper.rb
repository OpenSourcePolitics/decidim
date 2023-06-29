# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      module InitiativesHelper
        def export_dropdown_path(format, collection_ids)
          path = export_initiatives_path(format: format)
          return path if collection_ids.blank?

          ids = collection_ids.join(",")
          path.concat("?cid=#{ids}")
        end

        def export_dropdown(collection_ids = nil)
          render partial: "decidim/initiatives/admin/exports/dropdown", locals: { collection_ids: collection_ids }
        end

        def export_dropdowns(query)
          return export_dropdown if query.conditions.empty?

          export_dropdown.concat(export_dropdown(query.result.map(&:id)))
        end

        def dropdown_id(collection_ids)
          return "export-dropdown" if collection_ids.blank?

          "export-selection-dropdown"
        end
      end
    end
  end
end
