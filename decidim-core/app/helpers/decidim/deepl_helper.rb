# frozen_string_literal: true

module Decidim
  # Helper that provides convenient methods to deal with translated attributes.
  module DeeplHelper
    include Decidim::TranslatableAttributes

    # Help to display the translation link, needs translate_title and
    # translate_body helper to indicate where to inject the translated data
    def translate_button_helper_for(title:, body:, model:, current_locale:, default_locale:, options: {})
      return unless translation_available?

      translate_link(title, body, model, current_locale, default_locale, options)
    end

    def translate_helper_for(element:, model:)
      return unless translation_available?

      "#{target_helper(model)}_#{element}"
    end

    def translate_link(title, body, model, current_locale, default_locale, options)
      style = options[:class] ? "card__translate #{options[:class]}" : "card__translate"

      content_tag(:div, class: style) do
        link_to "#", class: "translatable_btn btn btn-secondary", data: {
          title: title,
          body: body,
          targetElem: target_helper(model),
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

    def target_helper(model)
      "#{model.class.name.demodulize.downcase}_#{model.id}"
    end

    def translation_available?
      current_organization.deepl_api_key.present? && current_organization.translatable_locales.count > 1
    end

    def deepl_target_locale(requested_locale, default_locale)
      return default_locale.upcase unless %w(EN DE FR ES PT IT NL PL RU).include? requested_locale.upcase

      requested_locale.upcase
    end
  end
end
