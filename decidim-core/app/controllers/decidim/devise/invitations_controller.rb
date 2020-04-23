# frozen_string_literal: true

module Decidim
  module Devise
    # This controller customizes the behaviour of Devise::Invitiable.
    class InvitationsController < ::Devise::InvitationsController
      include Decidim::DeviseControllers
      include NeedsTosAccepted
      helper_method :residential_area_for_select, :work_area_for_select, :gender_types_for_select, :month_names_for_select, :year_for_select

      before_action :configure_permitted_parameters

      # We don't users to create invitations, so we just redirect them to the
      # homepage.
      def authenticate_inviter!
        redirect_to root_path
      end

      # Overwrite the method that returns the path after a user accepts an
      # invitation. Using the param `invite_redirect` we can redirect the user
      # to a custom path after it has accepted the invitation.
      def after_accept_path_for(resource)
        params[:invite_redirect] || after_sign_in_path_for(resource)
      end

      # When a managed user accepts the invitation is promoted to non-managed user.
      def accept_resource
        resource = resource_class.accept_invitation!(update_resource_params)
        resource.update!(newsletter_notifications_at: Time.current) if update_resource_params[:newsletter_notifications]
        resource.update!(managed: false) if resource.managed?
        resource.update!(accepted_tos_version: resource.organization.tos_version)
        resource.update!(registration_metadata: registration_metadata(update_resource_params[:registration_metadata]))
        Decidim::Gamification.increment_score(resource.invited_by, :invitations) if resource.invited_by
        resource
      end

      private

      def registration_metadata(param)
        {
          work_area: param[:work_area],
          gender: param[:work_area],
          residential_area: param[:work_area],
          statutory_representative_email: statutory_representative_email(param),
          birth_date: birth_date(param)
        }
      end

      def birth_date(param)
        {
          month: param[:birth_date][:month],
          year: param[:birth_date][:year]
        }
      end

      def statutory_representative_email(param)
        param[:statutory_representative_email] if param[:underage].present?
      end

      protected

      def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:accept_invitation, keys: [:nickname, :tos_agreement, :newsletter_notifications, registration_metadata: {}])
      end

      GENDER_TYPES = %w(male female other).freeze

      MONTHNAMES = (1..12).map { |m| Date::MONTHNAMES[m] }.freeze

      def residential_area_for_select
        scopes
      end

      def work_area_for_select
        scopes
      end

      def gender_types_for_select
        GENDER_TYPES.map do |type|
          [
            I18n.t(type.downcase, scope: "decidim.devise.invitations.edit.gender"),
            type
          ]
        end
      end

      def month_names_for_select
        MONTHNAMES.map do |month_name|
          [
            I18n.t(month_name.downcase, scope: "decidim.devise.invitations.edit.month_name"),
            month_name
          ]
        end
      end

      def year_for_select
        (Time.current.year - 100..Time.current.year).map(&:to_s).reverse
      end

      def scopes
        current_organization.scopes
      end
    end
  end
end
