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

        errors = flatten_errors(amendable_form.errors.details) - flatten_errors(original_form.errors.details)
        @amendable_form.errors.clear
        add_errors(errors)

        @errors = amendable_form.errors
      end

      def flatten_errors(form_errors)
        form_errors.flat_map do |attribute, errors|
          errors.map do |error|
            error.flat_map { |_, value| [attribute, value] }
          end
        end
      end

      def add_errors(errors)
        errors.each do |attribute, error|
          amendable_form.errors.add(attribute, error)
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
