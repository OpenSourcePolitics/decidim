# frozen_string_literal: true

module Decidim
  class StatutoryRepresentativeMailer < ApplicationMailer
    def inform(user)
      return if user.email.blank?
      return if user.registration_metadata["statutory_representative_email"].blank?

      @user = user
      @statutory_representative_email = user.registration_metadata["statutory_representative_email"]
      @organization = user.organization

      with_user(user) do
        @subject = I18n.t("inform.subject", scope: "decidim.statutory_representative")
        @body = I18n.t("inform.body", scope: "decidim.statutory_representative", name: user.name, nickname: user.nickname, organization: @organization.name)

        mail(from: Decidim.config.mailer_sender, to: "#{@statutory_representative_email} <#{@statutory_representative_email}>", subject: @subject)
      end
    end
  end
end
