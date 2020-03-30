class AddSortChildrenOptionToAssembly < ActiveRecord::Migration[5.2]
  def change
    add_column :assemblies, :sort_children, :boolean, default: false
  end
end
