# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to create or update areas.
    class AreaForm < Form
      include TranslatableAttributes

      translatable_attribute :name, String
      attribute :organization, Decidim::Organization
      attribute :area_type_id, Integer
      attribute :color
      attribute :logo
      attribute :remove_logo

      mimic :area

      validates :name, translatable_presence: true
      validates :organization, presence: true
      validate :name_uniqueness
      validates :logo,
                file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } },
                file_content_type: { allow: ["image/png"] }
      validates :color, format: { with: /#[0-9a-fA-F]{6}|#[0-9a-fA-F]{3}/i }

      def name_uniqueness
        return unless organization
        return unless organization.areas.where(name: name, area_type: area_type).where.not(id: id).any?

        errors.add(:name, :taken)
      end

      alias organization current_organization

      def area_type
        Decidim::AreaType.find_by(id: area_type_id) if area_type_id
      end
    end
  end
end
