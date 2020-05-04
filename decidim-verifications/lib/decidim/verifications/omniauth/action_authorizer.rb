# frozen_string_literal: true

module Decidim
  module Verifications
    module Omniauth
      class ActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
        # attr_reader :allowed_postal_codes

        # Overrides the parent class method, but it still uses it to keep the base behavior
        def authorize
          status_code, data = *super

          # if allowed_postal_codes.present?
          #   # Does not authorize users with different postal codes
          #   if status_code == :ok && !allowed_postal_codes.member?(authorization.metadata["postal_code"])
          #     status_code = :unauthorized
          #     data[:fields] = { "postal_code" => authorization.metadata["postal_code"] }
          #   end
          #
          #   # Adds an extra message for inform the user the additional restriction for this authorization
          #   data[:extra_explanation] = { key: "extra_explanation",
          #                                params: { scope: "decidim.verifications.dummy_authorization",
          #                                          count: allowed_postal_codes.count,
          #                                          postal_codes: allowed_postal_codes.join(", ") } }
          # end

          [status_code, data]
        end

        # Adds the list of allowed postal codes to the redirect URL, to allow forms to inform about it
        # def redirect_params
        #   { "postal_codes" => allowed_postal_codes&.join("-") }
        # end
      end
    end
  end
end
