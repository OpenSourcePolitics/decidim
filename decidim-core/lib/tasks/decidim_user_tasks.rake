# frozen_string_literal: true

namespace :decidim do
  namespace :user do
    # All ------
    #
    # Get all metrics entities and execute his own rake task.
    # It admits a date-string parameter, in a 'YYYY-MM-DD' format from
    # today to all past dates
    desc "Destroy user accounts using decidim destroy_account command"

    task destroy_accounts: :environment do |_task, _args|
      raise ArgumentError unless ENV["RAILS_FORCE"] == "true"
    rescue ArgumentError => e
      puts "#{e} : Please run task with RAILS_FORCE='true' env variable to ensure your choice"
    end
  end
end
