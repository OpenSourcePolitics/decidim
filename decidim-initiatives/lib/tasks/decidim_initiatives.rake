# frozen_string_literal: true

require "decidim/initiatives/end_of_mandate_archivist"

namespace :decidim_initiatives do
  desc "Check validating initiatives and moves all without changes for a configured time to discarded state"
  task check_validating: :environment do
    Decidim::Initiatives::OutdatedValidatingInitiatives
      .for(Decidim::Initiatives.max_time_in_validating_state)
      .each(&:discarded!)
  end

  desc "Check published initiatives and moves to accepted/rejected state depending on the votes collected when the signing period has finished"
  task check_published: :environment do
    Decidim::Initiatives::SupportPeriodFinishedInitiatives.new.each do |initiative|
      if initiative.supports_goal_reached?
        initiative.accepted!
      else
        initiative.rejected!
      end
    end
  end

  desc "Notify progress on published initiatives"
  task notify_progress: :environment do
    Decidim::Initiative
      .published
      .where.not(first_progress_notification_at: nil)
      .where(second_progress_notification_at: nil).find_each do |initiative|
      if initiative.percentage >= Decidim::Initiatives.second_notification_percentage
        notifier = Decidim::Initiatives::ProgressNotifier.new(initiative: initiative)
        notifier.notify

        initiative.second_progress_notification_at = Time.now.utc
        initiative.save
      end
    end

    Decidim::Initiative
      .published
      .where(first_progress_notification_at: nil).find_each do |initiative|
      if initiative.percentage >= Decidim::Initiatives.first_notification_percentage
        notifier = Decidim::Initiatives::ProgressNotifier.new(initiative: initiative)
        notifier.notify

        initiative.first_progress_notification_at = Time.now.utc
        initiative.save
      end
    end
  end

  desc "Description"
  task :end_of_mandate_archive, [:archive_category_name, :organization_id] => :environment do |_task, args|
    if args.archive_category_name.blank? || args.organization_id.blank?
      raise ArgumentError, "You must pass a parameter: decidim_initiatives:end_of_mandate_archive[\"category_name\",organization_id]"
    end

    Decidim::Initiatives::EndOfMandateArchivist.archive(args.archive_category_name, args.organization_id)
  end
end
