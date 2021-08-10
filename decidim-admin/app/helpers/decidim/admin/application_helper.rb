# frozen_string_literal: true

module Decidim
  module Admin
    # Custom helpers, scoped to the admin panel.
    #
    module ApplicationHelper
      include Decidim::LocalizedLocalesHelper
      include Decidim::TranslationsHelper
      include Decidim::HumanizeBooleansHelper
      include Decidim::AriaSelectedLinkToHelper
      include Decidim::MetaTagsHelper
      include Decidim::MapHelper
      include Decidim::Admin::LogRenderHelper

      def title
        current_organization.name
      end

      # Adds a link to the secondary navigation so admins can easily access the public page of the
      # element their working on.
      #
      # url - The String with the URL to link to.
      #
      # Returns a String with a link wrapped in a <li> element.
      def public_page_link(url)
        content_tag(:li) do
          link_to url, class: "button", style: "color: #fff", target: "_blank" do
            I18n.t("decidim.admin.view_public_page")
          end
        end
      end

      def pseudomizable?(component)
        !%w(blogs pages surveys accountability meetings budgets).include? component.manifest_name
      end

      def pseudomization_status(component)
        cache_manager(component).read.presence
      end

      def current_pseudomization_status(component)
        pseudomization_status(component).dig(:current) || 0
      end

      def total_pseudomization_status(component)
        pseudomization_status(component).dig(:total) || "?"
      end

      private

      def cache_manager(component)
        Decidim::PseudomizeResourcesStatusManager.new(component)
      end
    end
  end
end
