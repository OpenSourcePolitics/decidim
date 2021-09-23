# frozen_string_literal: true

module Decidim
  module Admin
    # Custom helpers, scoped to the admin panel.
    #
    module PseudomizeHelper
      # Return icon with tooltip
      # State : String - "completed" || "running"
      def processing_pseudomization(component, state)
        content_tag :div, class: "action-icon-wrapper action-icon" do
          with_tooltip(
            t("actions.pseudomize.tooltip.running",
              current: current_pseudomization_status(component),
              total: total_pseudomization_status(component),
              scope: "decidim.admin")
          ) do
            icon "shield", class: "action-icon action-icon--disabled action-icon--#{state}"
          end
        end
      end

      # Returns true if component is pseudomizable
      def pseudomizable?(component)
        !%w(blogs pages surveys accountability meetings budgets).include? component.manifest_name
      end

      # Returns the component pseudomize_status
      # returns Hash or Nil
      def pseudomization_status(component)
        status_manager(component).read.presence
      end

      # If pseudomization is neither running nor completed, returns true
      def can_perform_pseudomization?(component)
        !pseudomization_running?(component) && !pseudomization_completed?(component)
      end

      # Check if pseudomization is running
      def pseudomization_running?(component)
        status_manager(component).task_running?
      end

      # Check if pseudomization is completed
      def pseudomization_completed?(component)
        status_manager(component).task_completed?
      end

      # Get the current state of pseudomization or returns 0
      def current_pseudomization_status(component)
        pseudomization_status(component)&.dig(:current) || 0
      end

      # Get the total of elements processed for pseudomization or returns "?"
      def total_pseudomization_status(component)
        pseudomization_status(component)&.dig(:total) || "?"
      end

      private

      # Returns the status manager for a component
      def status_manager(component)
        Decidim::PseudomizeResourcesStatusManager.new(component)
      end
    end
  end
end
