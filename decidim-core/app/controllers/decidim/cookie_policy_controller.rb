# frozen_string_literal: true

module Decidim
  # This controller allows the user to accept the cookie policy.
  class CookiePolicyController < Decidim::ApplicationController
    skip_before_action :store_current_location

    def accept
      response.set_cookie "decidim-cc", value: "true",
                                        path: "/",
                                        expires: 1.year.from_now.utc

      respond_to do |format|
        format.js
        format.html { redirect_back fallback_location: root_path }
      end
    end

    def show_terms
      content = {
        title: "Let us know you agree to cookies",
        description: "Un \"cookie\" est une suite d'informations, généralement de petite taille et identifié par un nom, qui peut être transmis à votre navigateur par un site web sur lequel vous vous connectez. Votre navigateur web le conservera pendant une certaine durée, et le renverra au serveur web chaque fois que vous vous y re-connecterez."
      }
      render partial: "decidim/cookie_policy/cookie_banner_modal", locals: { content: content }
    end
  end
end
