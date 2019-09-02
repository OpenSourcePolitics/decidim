# frozen_string_literal: true

module Decidim
  # Helper that provides convenient methods to deal with translated attributes.
  module DeeplHelper
    include Decidim::TranslatableAttributes

    def translate_button_helper_for(model, current_locale, default_locale, type)
      translate_link(model, current_locale, default_locale, type) if translation_available?
    end

    def translate_link(model, current_locale, default_locale, type)
      content_tag(:div, class: "card__translate") do
        link_to "#", class: "translatable_btn btn btn-secondary", data: {
          translatabletype: type,
          "translatable-id": model.id,
          targetlang: deepl_target_locale(current_locale, default_locale),
          translatable: true,
          translated: t("decidim.translated"),
          original: t("decidim.translate")
        } do
          link_content
        end
      end
    end

    def link_content
      content = icon "globe", class: "action-icon action-icon--disabled"
      content << content_tag(:span, t("decidim.translate"))
      content << content_tag(:div, "", class: "loading-spinner loading-spinner--hidden")
    end

    def translate_title_helper_for(model)
      "data-translatable-title=#{model.id}"
    end

    def translate_body_helper_for(model)
      "data-translatable-body=#{model.id}"
    end

    def translation_available?
      current_component.organization.deepl_api_key.present? && current_component.organization.translatable_locales.count > 1
    end

    def deepl_target_locale(requested_locale, default_locale)
      return default_locale.upcase unless %w(EN DE FR ES PT IT NL PL RU).include? requested_locale.upcase

      requested_locale.upcase
    end
  end
end
