# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to manage proposals in a participatory process.
    class PseudomizationsController < Decidim::Admin::ApplicationController
      include Decidim::ComponentPathHelper

      def create
        enforce_permission_to :pseudomize, :component, component: component

        PseudomizeComponent.call(component) do
          on(:ok) do
            flash[:notice] = "Success"
          end

          on(:invalid) do
            flash.now[:alert] = "Error"
          end

          # redirect_back(fallback_location: manage_component_path(component))
        end
      end

      private

      def component
        @component ||= Decidim::Component.find(params[:component_id])
      end
    end
  end
end
