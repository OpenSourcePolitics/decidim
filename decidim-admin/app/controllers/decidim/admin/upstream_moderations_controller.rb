# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to manage moderations in a participatory process.
    class UpstreamModerationsController < Decidim::Admin::ApplicationController
      helper_method :upstream_moderations, :allowed_to?
      helper Decidim::Messaging::ConversationHelper

      def index
        enforce_permission_to :read, :moderation
      end

      def accept
        enforce_permission_to :accept, :moderation

        Admin::AcceptUpstreamResource.call(upstream_reportable, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("reportable.accept.success", scope: "decidim.upstream_moderations.admin")
            redirect_to upstream_moderations_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("reportable.accept.invalid", scope: "decidim.upstream_moderations.admin")
            redirect_to upstream_moderations_path
          end
        end
      end

      def hide
        enforce_permission_to :hide, :moderation

        Admin::HideUpstreamResource.call(upstream_reportable, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("reportable.hide.success", scope: "decidim.upstream_moderations.admin")
            redirect_to upstream_moderations_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("reportable.hide.invalid", scope: "decidim.upstream_moderations.admin")
            redirect_to upstream_moderations_path
          end
        end
      end

      private

      def upstream_moderations
        @upstream_moderations ||= begin
          if params[:visible]
            participatory_space_upstream_moderations.visible
          elsif params[:not_visible]
            participatory_space_upstream_moderations.not_visible
          else
            participatory_space_upstream_moderations.pending_moderation
          end
        end
      end

      def upstream_reportable
        @upstream_reportable ||= participatory_space_upstream_moderations.find(params[:id]).upstream_reportable
      end

      def participatory_space_upstream_moderations
        @participatory_space_upstream_moderations ||= Decidim::UpstreamModeration.where(participatory_space: current_participatory_space)
      end
    end
  end
end
