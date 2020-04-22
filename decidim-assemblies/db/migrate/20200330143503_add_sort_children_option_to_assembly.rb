# frozen_string_literal: true

class AddSortChildrenOptionToAssembly < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_assemblies, :sort_children, :boolean, default: false
  end
end