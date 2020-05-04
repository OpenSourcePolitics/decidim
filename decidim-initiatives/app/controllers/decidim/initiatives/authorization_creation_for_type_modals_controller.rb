# frozen_string_literal: true

module Decidim
  module Initiatives
    class AuthorizationCreationForTypeModalsController < Decidim::Initiatives::ApplicationController
      include Decidim::UserProfile
      include Decidim::Initiatives::NeedsInitiative

      helper Decidim::Verifications::AntiAffinityHelper
      helper_method :authorizations, :authorize_action_path, :redirect_url, :initiative_type
      layout false

      def show
        render template: "decidim/authorization_modals/show"
      end

      private

      def redirect_url
        params[:redirect] || create_initiative_path(:previous_form)
      end

      def authorize_action_path(handler_name)
        authorizations.status_for(handler_name).current_path(redirect_url: redirect_url)
      end

      def authorizations
        @authorizations ||= action_authorized_to("create", resource: initiative_type, permissions_holder: initiative_type)
      end

      def initiative_type
        @initiative_type ||= Decidim::InitiativesType.find(params[:id])
      end
    end
  end
end
