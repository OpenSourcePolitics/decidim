# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A form object used to collect the all the initiative type attributes.
      class InitiativeTypeForm < Decidim::Form
        DEFAULT_MINIMUM_COMMITTEE_MEMBERS = 2

        include TranslatableAttributes

        mimic :initiatives_type

        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :banner_image, String
        attribute :signature_type, String
        attribute :undo_online_signatures_enabled, Boolean
        attribute :attachments_enabled, Boolean
        attribute :child_scope_threshold_enabled, Boolean
        attribute :custom_signature_end_date_enabled, Boolean
        attribute :area_enabled, Boolean
        attribute :only_global_scope_enabled, Boolean
        attribute :global_signature_end_date, Decidim::Attributes::LocalizedDate
        attribute :promoting_committee_enabled, Boolean
        attribute :comments_enabled, Boolean
        attribute :minimum_committee_members, Integer
        attribute :collect_user_extra_fields, Boolean
        translatable_attribute :extra_fields_legal_information, String
        attribute :validate_sms_code_on_votes, Boolean
        attribute :document_number_authorization_handler, String

        validates :title, :description, translatable_presence: true
        validates :attachments_enabled, :undo_online_signatures_enabled, :custom_signature_end_date_enabled,
                  :promoting_committee_enabled, :area_enabled, :comments_enabled, inclusion: { in: [true, false] }
        validates :minimum_committee_members, numericality: { only_integer: true }, allow_nil: true
        validates :banner_image, presence: true, if: ->(form) { form.context.initiative_type.nil? }
        validate :global_signature_end_date_error

        def minimum_committee_members=(value)
          super(value.presence)
        end

        def minimum_committee_members
          return 0 unless promoting_committee_enabled?
          return DEFAULT_MINIMUM_COMMITTEE_MEMBERS if super.blank?

          super
        end

        def global_signature_end_date_error
          if global_signature_end_date.present? && global_signature_end_date <= Time.current
            errors.add(:global_signature_end_date, I18n.t("global_signature_end_date_error", scope: "decidim.admin.initiative_type_form"))
          end
        end

        def signature_type_options
          Initiative.signature_types.keys.map do |type|
            [
              I18n.t(
                type,
                scope: %w(activemodel attributes initiative signature_type_values)
              ), type
            ]
          end
        end
      end
    end
  end
end
