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
      render partial: "decidim/cookie_policy/cookie_banner_modal", locals: { cookies: cookies_explanation }
    end

    private

    def cookies_explanation
      [
        { name: "session", url: "https://opensourcepolitics.eu/" },
        { name: "matomo_session", url: "https://fr.matomo.org/faq/general/faq_146/" },
        { name: "pk_id", url: "https://fr.matomo.org/faq/general/faq_146/" },
        { name: "pk_ses", url: "https://fr.matomo.org/faq/general/faq_146/" },
        { name: "test_cookie", url: "https://fr.matomo.org/faq/general/faq_146/" }
      ]
    end
  end
end
