# frozen_string_literal: true

module Decidim
  # This command destroys the user's account.
  class DestroyAccount < Rectify::Command
    # Destroy a user's account.
    #
    # user - The user to be updated.
    # form - The form with the data.
    def initialize(user, form, enabled_admin_email = true)
      @user = user
      @form = form
      @enabled_admin_email = enabled_admin_email
    end

    def call
      return broadcast(:invalid) unless @form.valid?

      Decidim::User.transaction do
        notify_admins if @enabled_admin_email
        destroy_user_account!
        destroy_user_identities
        destroy_user_group_memberships
        destroy_follows
      end

      broadcast(:ok)
    end

    private

    def notify_admins
      organizations_admins.each do |admin|
        DestroyAccountMailer.notify(admin).deliver_later
      end
    end

    def destroy_user_account!
      @user.name = ""
      @user.nickname = ""
      @user.email = ""
      @user.delete_reason = @form.delete_reason
      @user.admin = false if @user.admin?
      @user.deleted_at = Time.current
      @user.skip_reconfirmation!
      @user.remove_avatar!
      @user.save!
    end

    def destroy_user_identities
      @user.identities.destroy_all
    end

    def destroy_user_group_memberships
      Decidim::UserGroupMembership.where(user: @user).destroy_all
    end

    def destroy_follows
      Decidim::Follow.where(followable: @user).destroy_all
      Decidim::Follow.where(user: @user).destroy_all
    end

    def organizations_admins
      @user.organization.admins - [@user]
    end
  end
end
