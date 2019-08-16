# frozen_string_literal: true

module Decidim
  module Admin
    # This class contains helpers needed in order for component settings to
    # properly render.
    module SettingsHelper
      TYPES = {
        boolean: :check_box,
        integer: :number_field,
        string: :text_field,
        text: :text_area
      }.freeze

      # Public: Renders a form field that matches a settings attribute's
      # type.
      #
      # form      - The form in which to render the field.
      # attribute - The Settings::Attribute instance with the
      #             description of the attribute.
      # name      - The name of the field.
      # options   - Extra options to be passed to the field helper.
      #
      # Returns a rendered form field.
      def settings_attribute_input(form, attribute, name, options = {})
        if name == :projects_per_category_treshold
          form.projects_per_category_treshold_field(
            current_participatory_space.categories.first_class,
            Decidim::Budgets::Project.where(component: @component).size
          )
        elsif attribute.translated?
          form.send(:translated, form_method_for_attribute(attribute), name, options.merge(tabs_id: "#{options[:tabs_prefix]}-#{name}-tabs"))
        else
          form.send(form_method_for_attribute(attribute), name, options.merge(extra_options_for(name)))
        end
      end

      private

      def form_method_for_attribute(attribute)
        return :editor if attribute.type.to_sym == :text && attribute.editor?

        TYPES[attribute.type.to_sym]
      end

      # Adds extra HTML options to `budget_voting_rules_settings` fields.
      #
      # Used in the following script:
      # assets/javascripts/decidim/admin/form.js.es6
      #
      # Returns a Hash.
      def extra_options_for(field_name)
        case field_name
        when :vote_per_budget, :vote_threshold_percent
          { class: "per-budget-rule" }
        when :vote_per_project, :total_projects
          { class: "per-project-rule" }
        else
          {}
        end
      end

      # Decidim::Budgets' component global settings related to "voting rules".
      # The order is important, as it is maintained by Hash#slice.
      #
      # Used in the following partials:
      # views/decidim/admin/components/_settings_fields.html.erb
      # views/decidim/admin/components/_budget_voting_rules_settings_fields.html.erb
      #
      # Returns an Array.
      def budget_voting_rules_settings
        [
          :vote_per_budget,
          :vote_threshold_percent,
          :vote_per_project,
          :total_projects,
          :vote_per_category,
          :projects_per_category_treshold
        ]
      end
    end
  end
end
