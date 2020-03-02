# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # This controller allows admins to manage moderations in a participatory process.
      class UpstreamModerationsController < Decidim::Admin::UpstreamModerationsController
        include Concerns::ParticipatoryProcessAdmin

        def permissions_context
          super.merge(current_participatory_space: current_participatory_space)
        end
      end
    end
  end
end
