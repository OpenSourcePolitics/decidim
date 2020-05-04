# frozen_string_literal: true

module Decidim
  module Verifications
    module Omniauth
      class ConfirmOmniauthAuthorization < Decidim::Verifications::ConfirmUserAuthorization
        def call
          return broadcast(:invalid) unless form.valid?

          if confirmation_successful?
            authorization.attributes = {
              unique_id: form.unique_id,
              encrypted_metadata: Decidim::MetadataEncryptor.new(
                uid: form.unique_id
              ).encrypt(form.metadata.reject { |k, _v| k == :nickname })
            }

            authorization.grant!
            broadcast(:ok)
          else
            broadcast(:invalid)
          end
        end
      end
    end
  end
end
