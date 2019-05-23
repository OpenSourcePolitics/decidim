class AddDeeplTranslatorApiKeyToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :api_key, :string
  end
end
