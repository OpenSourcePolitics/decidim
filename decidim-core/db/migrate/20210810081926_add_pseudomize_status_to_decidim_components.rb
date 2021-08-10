# frozen_string_literal: true

class AddPseudomizeStatusToDecidimComponents < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_components, :pseudomize_status, :jsonb
  end
end
