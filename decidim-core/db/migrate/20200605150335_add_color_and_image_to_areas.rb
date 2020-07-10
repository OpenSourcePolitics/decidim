class AddColorAndImageToAreas < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_areas, :color, :string
    add_column :decidim_areas, :logo, :string
  end
end
