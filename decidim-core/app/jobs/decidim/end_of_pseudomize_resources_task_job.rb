# frozen_string_literal: true

module Decidim
  class EndOfPseudomizeResourcesTaskJob < ApplicationJob
    queue_as :default

    def perform(user, cache_entry)
      if task_completed?(cache_entry)
        notify_admin(user)
        erase_cache_entry!(cache_entry)
      else
        args = arguments
        Decidim::EndOfPseudomizeResourcesTaskJob.set(wait: 1.minute).perform_later(args.first, args.last)
      end
    end

    private

    def task_completed?(cache_entry)
      return true if read_cache_entry(cache_entry).nil?

      total = read_cache_entry(cache_entry).dig(:total)
      current = read_cache_entry(cache_entry).dig(:current)

      current == total
    end

    def read_cache_entry(cache_entry)
      Rails.cache.fetch(cache_entry)
    end

    def notify_admin(user)
      Decidim::Admin::PseudomizeMailer.notify_admin(user)
    end

    def erase_cache_entry!(cache_entry)
      Rails.cache.write(cache_entry, nil)
    end
  end
end
