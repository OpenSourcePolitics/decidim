# frozen_string_literal: true

module Decidim
  module Verifications
    module Omniauth
      class AuthorizationsController < Decidim::ApplicationController
        helper_method :authorization

        before_action :load_authorization

        def new
          # TODO : create abstract route for omniauth actions
          # TODO : validate action BEFORE launch the OmniAuth process
          # store_location_for(:redirect, request.referer))
          # Rails.logger.debug "+++++++++++++++++++++++++"
          # Rails.logger.debug "AuthorizationsController.new"
          # Rails.logger.debug "request.fullpath --> " + request.fullpath.to_s
          # Rails.logger.debug "request.referer --> " + request.referer.to_s
          # Rails.logger.debug params
          # Rails.logger.debug "location_for :user --> " + store_location_for(:user, stored_location_for(:user)).to_s
          # Rails.logger.debug "redirect_url will be " + redirect_url
          # Rails.logger.debug "+++++++++++++++++++++++++"
          store_location_for(:user, request.fullpath)
          store_location_for(:redirect, redirect_url)
          redirect_to decidim.send("user_#{provider}_omniauth_authorize_path")
        end

        private

        def redirect_url
          @redirect_url ||= params[:redirect_url] || request.referer || decidim_verifications.authorizations_path
        end

        def authorization
          @authorization ||= AuthorizationPresenter.new(@authorization)
        end

        def load_authorization
          @authorization = Decidim::Authorization.find_or_initialize_by(
            user: current_user,
            name: handler_name
          )
        end

        def handler_name
          @handler_name ||= url_options[:script_name].split("/").detect(&:present?)
        end

        def handler
          @handler ||= Decidim::Verifications.find_workflow_manifest(handler_name)
        end

        def provider
          @provider ||= handler.omniauth_provider
        end

        def main_engine
          @main_engine ||= Decidim::Verifications::Adapter.from_element(handler_name).send("decidim_#{handler_name}")
        end
      end
    end
  end
end
