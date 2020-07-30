# frozen_string_literal: true

# Critical tasks, DO NOT USE in production
# Allows to manipulate data from DB
namespace :user do
  desc "Destroy account using destroy_account core command"
  task :destroy_accounts, :environment do
    exit(2) unless prompt("destroy_accounts is a critical command, please confirm your choice [y/n] ") == "y"

    users = Decidim::User
            .not_deleted
            .not_confirmed
            .where(current_sign_in_at: nil)
            .where(last_sign_in_at: nil)
            .where(current_sign_in_ip: nil)
            .where(last_sign_in_at: nil)
            .where(invitation_accepted_at: nil)
            .where(admin: false)
            .where.not(invitation_token: nil)
            .where("invitation_sent_at <= ?", Date.new(2020, 7, 1))

    exit(1) unless users.count.positive?

    action_resume(users.count)
    exit(2) unless prompt("Are you sur you want to definitively destroy those #{users.count} users ? [y/n] ") == "y"

    destroy_account_form = Decidim::DeleteAccountForm.new(delete_reason: "Supprimé par l'administration pour des raisons RGPD")

    users.each do |user|
      Decidim::DestroyAccount.new(user, destroy_account_form).call
    end
  rescue SystemExit => e
    puts "No users found, rake task aborted : Exit status #{e.status}" if e.status == 1
    puts "Choice not confirmed, rake task aborted : Exit status #{e.status}" if e.status == 2
  else
    puts "\nRake task exited successfully !"
  end
end

# Returns user input from STDIN
def prompt(*args)
  print(*args)
  STDIN.gets.chomp
end

# Print on STDOUT a light resume of total users destroyed by command
def action_resume(total)
  puts "######### Users Found ! #############\n
More informations about users : \n
Total destroyed: #{total} \n
######################################\n"
end
