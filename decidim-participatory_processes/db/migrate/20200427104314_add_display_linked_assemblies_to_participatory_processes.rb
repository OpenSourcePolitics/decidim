# frozen_string_literal: true

class AddDisplayLinkedAssembliesToParticipatoryProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :display_linked_assemblies, :boolean, default: false
  end
end
