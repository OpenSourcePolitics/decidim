# frozen_string_literal: true

module Decidim
  class PseudomizeResourcesCacheManager
    def initialize(component)
      @component = component
    end

    def write_to_cache(value)
      Rails.logger.info("Writing to entry: #{cache_entry} with value: #{value}")
      Rails.cache.write(cache_entry, value)
    end

    def read_from_cache
      Rails.logger.info("Reading from entry: #{cache_entry}")
      Rails.cache.fetch(cache_entry)
    end

    def mark_as_running
      Rails.logger.info("Marking as running")
      write_to_cache(pending: true)
    end

    def erase_cache_entry!
      Rails.logger.info("Erasing #{cache_entry}")
      Rails.cache.write(cache_entry, {})
    end

    def task_completed?
      return true if read_from_cache == {}
      return false if read_from_cache.nil?

      total = read_from_cache.dig(:total)
      current = read_from_cache.dig(:current)

      current == total
    end

    def task_running?
      return false if read_from_cache == {}
      return false if read_from_cache.nil?

      read_from_cache.dig(:pending)
    end

    def increment_resources_counter!
      Rails.logger.info("Incrementing entry: #{cache_entry}")
      entry = read_from_cache
      new_entry = entry.dup.merge(current: entry[:current] + 1)
      write_to_cache(new_entry)
    end

    private

    def cache_entry
      "pseudomize_resources_#{@component.manifest_name}_#{@component.id}"
    end
  end
end
