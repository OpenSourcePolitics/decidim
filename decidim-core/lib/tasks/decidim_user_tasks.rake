# frozen_string_literal: true

namespace :decidim do
  namespace :user do
    # destroy_accounts ------
    #
    # Destroy user accounts using destroy_account decidim's command.
    # Account concerned are those which seems not to sign again on platform.
    # This command is usefull when administrator needs to remove user accounts that have been collected from old platform but don't connect again
    desc "Destroy user accounts using decidim destroy_account command"

    task destroy_accounts: :environment do |_task, _args|
      raise ArgumentError unless ENV["RAILS_FORCE"] == "true"

      destroy_account_form = Decidim::DeleteAccountForm.new(delete_reason: "Supprimé par l'administration pour des raisons RGPD")
      users = Decidim::User.not_confirmed
                           .not_deleted
                           .where(admin: false) # user is not admin
                           .where("invitation_sent_at <= ?", invitation_sent_date_limit) # Do not destroy accounts invited during the current month
                           .where(invitation_accepted_at: nil) # Account must have a pending acceptation
                           .where.not(invitation_token: nil) # Account must have a pending invitation token
                           .where(last_sign_in_at: nil) # Account have to never been connected on platform

      users.each do |user|
        Decidim::DestroyAccount.new(user, destroy_account_form).call
      end

      puts "#{users.count} accounts have been successfully destroyed"
    rescue ArgumentError => e
      puts "#{e} : Please run task with RAILS_FORCE='true' env variable to ensure your choice"
      puts "-----"
      puts "OPTIONAL : Use DATE_LIMIT to redefine invitation date limit"
      puts "Format: DATE_LIMIT='yyyy-mm-dd'"
    ensure
      ENV.delete "RAILS_FORCE"
      ENV.delete "DATE_LIMIT" if ENV["DATE_LIMIT"].present?
    end
  end
end

def invitation_sent_date_limit
  if ENV["DATE_LIMIT"]
    return ENV["DATE_LIMIT"].to_date if ENV["DATE_LIMIT"].to_date.is_a? Date
  end

  Date.current - 1.month
end
