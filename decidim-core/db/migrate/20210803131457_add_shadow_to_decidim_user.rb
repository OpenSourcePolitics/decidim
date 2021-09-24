# frozen_string_literal: true

class AddShadowToDecidimUser < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :shadow, :boolean, default: false
  end
end
