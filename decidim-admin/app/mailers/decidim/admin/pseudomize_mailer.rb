# frozen_string_literal: true

module Decidim
  module Admin
    class PseudomizeMailer < Decidim::ApplicationMailer
      def notify_admin(admin)
        send_mail_to(admin, "decidim.admin.pseudomize_mailer.notify_admin")
      end

      def notify_user(user)
        send_mail_to(user, "decidim.admin.pseudomize_mailer.notify_user")
      end

      private

      def send_mail_to(user, subject_key)
        with_user(user) do
          @user = user
          @organization = user.organization
          subject = I18n.t("subject", scope: subject_key)
          mail(from: Decidim.config.mailer_sender, to: user.email, subject: subject)
        end
      end
    end
  end
end
