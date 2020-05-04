# frozen_string_literal: true

class AddCommentsEnabledToInitiativeTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_initiatives_types, :comments_enabled, :boolean, null: false, default: true
  end
end
