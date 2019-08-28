# frozen_string_literal: true

module Decidim
  module Budgets
    # A helper to render order and budgets actions
    module ProjectsHelper
      # Render a budget as a currency
      #
      # budget - A integer to represent a budget
      def budget_to_currency(budget)
        number_to_currency budget, unit: Decidim.currency_unit, precision: 0
      end

      # Return a percentage of the current order budget from the total budget
      def current_order_budget_percent
        current_order&.budget_percent.to_f.floor
      end

      # Return a percentage of the current order project from total projects
      def current_order_project_percent
        current_order&.project_percent.to_f.floor
      end

      def current_order_percent_minimum
        return 100 if component_settings.vote_per_project

        100 - component_settings.vote_threshold_percent
      end

      def current_order_percent
        return current_order_budget_percent if component_settings.vote_per_budget

        current_order_project_percent
      end

      # Return true if the current order is checked out
      delegate :checked_out?, to: :current_order, prefix: true, allow_nil: true

      # Return true if the current order is pending
      delegate :pending?, to: :current_order, prefix: true, allow_nil: true

      # Return true if the user can continue to the checkout process
      def current_order_can_be_checked_out?
        current_order&.can_checkout?
      end

      def border_helper(project)
        return unless project&.category
        return "" if project.category.color.blank?

        "border: 1px solid #{project.category.color}; border-top: 3px solid #{project.category.color};"
      end

      # Return true if the order process is pending
      def current_order_is_pending?
        current_order&.pending?
      end

      def budget_summary_state
        return "budget_summary_state--completed" if current_order_can_be_checked_out?
        return "budget_summary_state--pending" if current_order_is_pending?

        ""
      end

      def progress_meter_state
        return "progress_meter_state--completed" if current_order_can_be_checked_out?
        return "progress_meter_state--pending" if current_order_is_pending?

        ""
      end

      # Return the minimum budget as Integer based on current_component settings.
      def minimum_budget
        current_component.settings.total_budget.to_f * (current_component.settings.vote_threshold_percent.to_f / 100)
      end

      # Return the current_component `projects_per_category_treshold` Hash,
      # with key-values as Integer and keeping only positive values.
      def projects_per_category_treshold
        @projects_per_category_treshold ||= Order.projects_per_category_treshold(current_component)
      end

      # Return the budget assigned to the current_order or zero if there isn't yet an order.
      # Return an Integer.
      def current_order_assigned_budget
        current_order&.total_budget || 0
      end

      # Return the number of projects added to the current_order or zero if there isn't yet an order.
      # Return an Integer.
      def current_order_projects_count
        current_order&.total_projects || 0
      end

      # Checks if the current_order can be checked out.
      # Returns a String.
      def vote_button_disabled?
        current_order_can_be_checked_out? ? "" : "disabled"
      end

      # Render a `button_to` form to DELETE a project with a trash icon.
      # Returns a HTML safe String.
      def remove_project_trash_icon_button(project)
        button_to(
          order_line_item_path(project_id: project),
          method: :delete,
          remote: true,
          data: { disable: true },
          form: { style: "display: inline" }
        ) do
          concat icon("trash", aria_label: t("remove", scope: "decidim.budgets.projects"), role: "img")
        end
      end

      # Render a `button_to` form to ADD a project but conditionally renders a popup modal blocking the action.
      # See Decidim::ActionAuthorizationHelper#action_authorized_button_to
      # Returns a HTML safe String.
      def add_project_authorized_button(project, css_classes, translation = nil, &block)
        arguments = [order_line_item_path(project_id: project),
                     method: :post,
                     remote: true,
                     data: { disable: true, add: true, budget: project.budget, "redirect-url": project_path(project) },
                     disabled: !current_settings.votes_enabled?,
                     class: css_classes]
        if block
          action_authorized_button_to("vote", *arguments, &block)
        else
          action_authorized_button_to("vote", translation, *arguments)
        end
      end

      # Render a `button_to` form to DELETE a project but conditionally renders a popup modal blocking the action.
      # See Decidim::ActionAuthorizationHelper#action_authorized_button_to
      # Returns a HTML safe String.
      def remove_project_authorized_button(project, css_classes, translation = nil, &block)
        arguments = [order_line_item_path(project_id: project),
                     method: :delete,
                     remote: true,
                     data: { disable: true, budget: project.budget, "redirect-url": project_path(project) },
                     disabled: !current_settings.votes_enabled?,
                     class: css_classes]
        if block
          action_authorized_button_to("vote", *arguments, &block)
        else
          action_authorized_button_to("vote", translation, *arguments)
        end
      end
    end
  end
end
