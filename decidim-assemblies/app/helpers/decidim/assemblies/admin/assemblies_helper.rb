# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # This class contains helpers needed to format ParticipatoryProcesses
      # in order to use them in select forms for AssemblyParticipatoryProcess.
      #
      module AssembliesHelper
        # Public: A formatted collection of ParticipatoryProcesses to be used
        # in forms.
        def processes_selected
          @processes_selected ||= current_assembly.linked_participatory_space_resources(:participatory_processes, "included_participatory_processes").pluck(:id) if current_assembly.present?
        end

        # Public: A collection of Assemblies that can be selected as parent
        # assemblies for another assembly; to be used in forms.
        def parent_assemblies_for_select
          @parent_assemblies_for_select ||= ParentAssembliesForSelect.for(current_organization, current_assembly)
        end
      end
    end
  end
end
