# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing all navbar links at the admin panel.
    #
    class NavbarLinksController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"
      helper_method :navbar_link

      def index
        authorize! :index, NavbarLink
        @navbar_links = current_organization.navbar_links
      end

      def new
        authorize! :new, NavbarLink
        @form = form(NavbarLinkForm).instance
      end

      def create
        authorize! :new, NavbarLink
        @form = form(NavbarLinkForm).from_params(params)

        CreateNavbarLink.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("navbar_links.create.success", scope: "decidim.admin")
            redirect_to navbar_links_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("navbar_links.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def edit
        authorize! :update, navbar_link
        @form = form(NavbarLinkForm).from_model(navbar_link)
      end

      def update
        authorize! :update,  navbar_link
        @form = form(NavbarLinkForm).from_params(params)

        UpdateNavbarLink.call(@form, navbar_link) do
          on(:ok) do
            flash[:notice] = I18n.t("navbar_links.update.success", scope: "decidim.admin")
            redirect_to navbar_links_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("navbar_links.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      def destroy
        authorize! :destroy, navbar_link
        navbar_link.destroy!

        flash[:notice] = I18n.t("navbar_links.destroy.success", scope: "decidim.admin")

        redirect_to navbar_links_path
      end

      private

      def navbar_link
        navbar_link = NavbarLink.find(params[:id])
      end
    end
  end
end
