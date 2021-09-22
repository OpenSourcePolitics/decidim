# frozen_string_literal: true

module Decidim
  class PseudomizeResourcesStatusManager
    def initialize(component)
      @component = component
    end

    def write(value)
      @component.reload.update!(pseudomize_status: value)
    end

    def read
      @component.reload.pseudomize_status&.symbolize_keys
    end

    def mark_as_running(total)
      write(total: total, current: 0)
    end

    def task_completed?
      return false if read.blank?

      read.dig(:total) == read.dig(:current)
    end

    def task_running?
      return false if read.blank?

      !task_completed?
    end

    def increment_resources_counter!
      write read.merge(current: read[:current] + 1)
    end
  end
end
