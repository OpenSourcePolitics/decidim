# frozen_string_literal: true

module Decidim
  # Service to encrypt and decrypt metadata
  class MetadataEncryptor
    def initialize(uid:)
      @key = ActiveSupport::KeyGenerator.new(uid).generate_key(
        Rails.application.secrets.secret_key_base, ActiveSupport::MessageEncryptor.key_len
      )
    end

    def encrypt(data)
      encryptor.encrypt_and_sign(data)
    end

    def decrypt(encrypted_data)
      encryptor.decrypt_and_verify(encrypted_data)
    end

    private

    def encryptor
      ActiveSupport::MessageEncryptor.new(@key)
    end
  end
end
