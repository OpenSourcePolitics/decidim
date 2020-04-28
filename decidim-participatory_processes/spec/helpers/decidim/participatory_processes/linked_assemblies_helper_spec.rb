# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    describe LinkedAssembliesHelper, type: :helper do
      let!(:process) { create(:participatory_process) }
      let!(:assemblies) { create_list(:assembly, 3, organization: process.organization) }

      describe "#linked_assemblies_for" do
        before do
          assemblies.each { |assembly| link_participatory_processes(assembly, process) }
        end

        it "doesn't displays linked assemblies" do
          expect(helper.linked_assemblies_for(process)).to be_empty
        end

        context "when display linked assemblies is set to true" do
          let!(:process) { create(:participatory_process, :display_linked_assemblies) }

          it "returns assemblies" do
            expect(helper.linked_assemblies_for(process)).to match_array(assemblies)
          end
        end
      end

      def link_participatory_processes(assembly, process)
        assembly.link_participatory_spaces_resources(process, "included_participatory_processes")
      end
    end
  end
end
