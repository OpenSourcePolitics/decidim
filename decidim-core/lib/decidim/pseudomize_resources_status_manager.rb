# frozen_string_literal: true

module Decidim
  class PseudomizeResourcesStatusManager
    def initialize(component)
      @component = component
    end

    def write(value)
      @component.update!(pseudomize_status: value)
    end

    def read
      @component.pseudomize_status&.symbolize_keys
    end

    def mark_as_running
      write(pending: true)
    end

    def erase_entry!
      write({})
    end

    def task_completed?
      return true if read == {}
      return false if read.nil?

      total = read.dig(:total)
      current = read.dig(:current)

      current == total
    end

    def task_running?
      return false if read == {}
      return false if read.nil?

      read.dig(:pending)
    end

    def increment_resources_counter!
      new_entry = read.dup.merge(current: read[:current] + 1)
      write(new_entry)
    end
  end
end
