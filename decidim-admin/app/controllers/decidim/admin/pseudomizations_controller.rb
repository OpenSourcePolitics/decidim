# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to manage proposals in a participatory process.
    class PseudomizationsController < Decidim::Admin::ApplicationController
      include Decidim::ComponentPathHelper

      def create
        enforce_permission_to :pseudomize, :component, component: component

        PseudomizeComponent.call(current_user, component) do
          on(:ok) do
            flash[:notice] = I18n.t("pseudomization.create.success", scope: "decidim.admin")
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("pseudomization.create.error", scope: "decidim.admin")
          end

          head :no_content
        end
      end

      private

      def component
        @component ||= Decidim::Component.find(params[:component_id])
      end
    end
  end
end
