# frozen_string_literal: true

module Decidim
  class DestroyAccountMailer < Decidim::ApplicationMailer
    def notify(user)
      with_user(user) do
        @organization = user.organization
        @user = user
        subject = I18n.t("notify.subject", scope: "decidim.destroy_account_mailer")
        mail(to: user.email, subject: subject)
      end
    end
  end
end
