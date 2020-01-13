# frozen_string_literal: true

module Decidim
  # A command with all the business logic to create a user through the sign up form.
  class CreateRegistration < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    def initialize(form)
      @form = form
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the form wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?

      create_user

      send_email_to_statutory_representative

      broadcast(:ok, @user)
    rescue ActiveRecord::RecordInvalid
      broadcast(:invalid)
    end

    private

    attr_reader :form

    def create_user
      @user = User.create!(
        email: form.email,
        name: form.name,
        nickname: form.nickname,
        password: form.password,
        password_confirmation: form.password_confirmation,
        organization: form.current_organization,
        tos_agreement: form.tos_agreement,
        newsletter_notifications_at: form.newsletter_at,
        email_on_notification: true,
        accepted_tos_version: form.current_organization.tos_version,
        registration_metadata: registration_metadata
      )
    end

    def registration_metadata
      {
        residential_area: form.residential_area,
        work_area: form.work_area,
        gender: form.gender,
        birth_date: form.birth_date,
        statutory_representative_email: statutory_representative_email
      }
    end

    def statutory_representative_email
      form.statutory_representative_email if form.underage.present?
    end

    def send_email_to_statutory_representative
      return if registration_metadata[:statutory_representative_email].blank?

      Decidim::StatutoryRepresentativeMailer.inform(@user).deliver_later
    end
  end
end
