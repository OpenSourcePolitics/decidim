# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A form object used to manage the initiative answer in the
      # administration panel.
      class InitiativeAnswerForm < Form
        include TranslatableAttributes

        mimic :initiative

        translatable_attribute :answer, String
        attribute :answer_url, String
        attribute :signature_start_date, Decidim::Attributes::LocalizedDate
        attribute :signature_end_date, Decidim::Attributes::LocalizedDate
        attribute :state, String
        attribute :answer_date, Decidim::Attributes::LocalizedDate

        validates :signature_start_date, :signature_end_date, presence: true, if: :signature_dates_required?
        validates :signature_end_date, date: { after: :signature_start_date }, if: lambda { |form|
          form.signature_start_date.present? && form.signature_end_date.present?
        }
        validates :state, presence: true
        validate :state_validation
        validates :answer_date, presence: true, if: :answer_date_allowed?
        validate :answer_date_restriction, if: :answer_date_allowed?

        def signature_dates_required?
          @signature_dates_required ||= check_state
        end

        def state_updatable?
          manual_states.include? context.initiative.state
        end

        def uniq_states
          (Decidim::Initiative::AUTOMATIC_STATES + Decidim::Initiative::MANUAL_STATES).uniq.map(&:to_s)
        end

        def manual_states
          Decidim::Initiative::MANUAL_STATES.map(&:to_s)
        end

        def answer_date_allowed?
          return false if state == "published"

          state_updatable?
        end

        def state_validation
          errors.add(:state, :invalid) if !state_updatable? && context.initiative.state != state
          errors.add(:state, :invalid) unless uniq_states.include? state
        end

        def answer_date_restriction
          errors.add(:answer_date, I18n.t("must_be_before", scope: "errors.messages", date: I18n.localize(Date.current, format: :decidim_short))) unless answer_date <= Date.current
        end

        private

        def check_state
          manual_states.include? context.initiative.state
        end
      end
    end
  end
end
