# frozen_string_literal: true

class AddEncryptedMetadataToAuthorizations < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_authorizations, :encrypted_metadata, :text
    Decidim::Authorization.find_each do |authorization|
      authorization.encrypted_metadata = Decidim::MetadataEncryptor.new(
        uid: authorization.unique_id
      ).encrypt(authorization.metadata)
    end
    remove_column :decidim_authorizations, :metadata
  end
end
