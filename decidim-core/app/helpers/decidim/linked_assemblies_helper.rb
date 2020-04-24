# frozen_string_literal: true

module Decidim
  # Common logic to filter resources
  module LinkedAssembliesHelper
    def linked_assemblies_for(process)
      process.linked_participatory_space_resources(:assembly, "included_participatory_processes")
             .published
    end
  end
end
