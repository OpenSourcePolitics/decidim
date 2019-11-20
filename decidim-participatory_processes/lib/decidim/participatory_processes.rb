# frozen_string_literal: true

require "decidim/participatory_processes/admin"
require "decidim/participatory_processes/engine"
require "decidim/participatory_processes/admin_engine"
require "decidim/participatory_processes/participatory_space"

module Decidim
  # Base module for the participatory processes engine.
  module ParticipatoryProcesses
    autoload :ParticipatoryProcessStepType, "decidim/participatory_processes/participatory_process_step_type"
    autoload :ParticipatoryProcessType, "decidim/participatory_processes/participatory_process_type"
    # Public: Stores an instance of ViewHooks
    def self.view_hooks
      @view_hooks ||= ViewHooks.new
    end
  end
end
