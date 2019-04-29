# frozen_string_literal: true

class AddColorToDecidimCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_categories, :color, :string
  end
end
