# frozen_string_literal: true

module Decidim
  # Common logic to filter resources
  module ParticipatoryProcesses
    module LinkedAssembliesHelper
      def assemblies_for_participatory_process(participatory_process_assemblies)
        html = ""
        html += %( <div class="section"> ).html_safe
        html += %( <h4 class="section-heading">#{t("participatory_process.show.related_assemblies", scope: "decidim")}</h4> ).html_safe
        html += %( <div class="row small-up-1 medium-up-2 card-grid"> ).html_safe
        participatory_process_assemblies.each do |participatory_process_assembly|
          html += render partial: "decidim/assemblies/assembly", locals: { assembly: participatory_process_assembly }
        end
        html += %( </div> ).html_safe
        html += %( </div> ).html_safe

        html.html_safe
      end

      def linked_assemblies_for(process)
        return [] unless process.display_linked_assemblies?

        process.linked_participatory_space_resources(:assembly, "included_participatory_processes")
            .published
      end
    end
  end
end
