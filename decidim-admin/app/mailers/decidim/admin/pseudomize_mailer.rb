# frozen_string_literal: true

module Decidim
  module Admin
    class PseudomizeMailer < Decidim::ApplicationMailer
      def notify_admin(admin)
        with_user(user) do
          @user = admin
          @organization = user.organization
          subject = I18n.t("subject", scope: "decidim.admin.pseudomize_mailer.notify_admin")
          mail(from: Decidim.config.mailer_sender, to: user.email, subject: subject)
        end
      end

      def notify_user(user)
        with_user(user) do
          @user = user
          @organization = user.organization
          subject = I18n.t("subject", scope: "decidim.admin.pseudomize_mailer.notify_user")
          mail(from: Decidim.config.mailer_sender, to: user.email, subject: subject)
        end
      end

      def notify_users(users)
        users.each { |user| notify_user(user) }
      end
    end
  end
end
