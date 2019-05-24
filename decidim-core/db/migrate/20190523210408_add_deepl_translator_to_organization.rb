# frozen_string_literal: true

class AddDeeplTranslatorToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_organizations, :deepl_api_key, :string
    add_column :decidim_organizations, :deepl_default_language, :string
  end
end
