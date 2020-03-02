# frozen_string_literal: true

module Decidim
  module Admin
    class UpstreamModerationMailer < Decidim::ApplicationMailer
      # frozen_string_literal: true
      helper Decidim::ResourceHelper
      helper_method :reported_content_url, :manage_moderations_url

      def notify_moderator(user, upstream_reportable)
        with_user(user) do
          @upstream_reportable = upstream_reportable
          @participatory_space = @upstream_reportable.component.participatory_space
          @organization = user.organization
          @user = user
          subject = I18n.t("moderator_subject", scope: "decidim.events.admin.upstream_pending")
          mail(from: Decidim.config.mailer_sender, to: user.email, subject: subject)
        end
      end

      private

      def reported_content_url
        @reported_content_url ||= @upstream_reportable.reported_content_url
      end

      def manage_moderations_url
        @manage_moderations_url ||= EngineRouter.admin_proxy(@participatory_space).upstream_moderations_url(host: @organization.host)
      end
    end
  end
end
