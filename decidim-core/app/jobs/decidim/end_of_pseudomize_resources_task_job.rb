# frozen_string_literal: true

module Decidim
  class EndOfPseudomizeResourcesTaskJob < ApplicationJob
    queue_as :default

    def perform(_user, _component)
      if status_manager.task_completed?
        notify_admin!
        status_manager.erase_entry!
      else
        Decidim::EndOfPseudomizeResourcesTaskJob.set(wait: 1.minute).perform_later(arguments.first, arguments.last)
      end
    end

    private

    def notify_admin!
      Decidim::Admin::PseudomizeMailer.notify_admin(arguments.first)
    end

    def status_manager
      @status_manager ||= Decidim::PseudomizeResourcesStatusManager.new(arguments.last)
    end
  end
end
