# frozen_string_literal: true

module Decidim
  module Amendable
    # a form object common for amendments
    class Form < Decidim::Form
      mimic :amendment

      def amendment
        @amendment ||= Decidim::Amendment.find_by(id: id)
      end

      def amendable
        @amendable ||= amendment&.amendable
      end

      def emendation
        @emendation ||= amendment&.emendation
      end

      def check_amendable_form_validations
        parse_hashtaggable_params
        run_validations

        errors_diff = (amendable_form.errors.details.to_a - original_form.errors.details.to_a).to_h
        @amendable_form.errors.clear
        add_errors(errors_diff)

        @errors = amendable_form.errors
      end

      def add_errors(errors_diff)
        errors_diff.each do |attribute, value|
          value.each { |error| amendable_form.errors.add(attribute, error[:error]) }
        end
      end

      def parse_hashtaggable_params
        emendation_params.each do |key, value|
          next unless [:title, :body].include?(key)
          emendation_params[key] = Decidim::ContentProcessor
                                   .parse_with_processor(
                                     :hashtag,
                                     value,
                                     current_organization: amendable.organization
                                   ).rewrite
        end
      end

      def amendable_form
        @amendable_form ||= amendable
                            .amendable_form
                            .from_params(emendation_params)
                            .with_context(
                              current_component: amendable.component,
                              current_participatory_space: amendable.participatory_space
                            )
      end

      def original_form
        @original_form ||= amendable
                           .amendable_form
                           .from_model(amendable)
                           .with_context(
                             current_component: amendable.component,
                             current_participatory_space: amendable.participatory_space
                           )
      end

      # Run validations only if `@amendable_form` is `nil`. This preserves
      # the artificial errors (:identical) added in `create_form.rb`
      def run_validations
        return if @amendable_form.present?

        original_form.validate
        amendable_form.validate
      end
    end
  end
end
