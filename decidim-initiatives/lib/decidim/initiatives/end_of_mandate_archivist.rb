# frozen_string_literal: true

module Decidim
  module Initiatives
    class EndOfMandateArchivist
      def initialize(category_name, organization_id, verbose)
        @organization = find_organization(organization_id)
        @category = find_or_create_category(category_name)
        @verbose = verbose
      end

      def self.archive(category_name, organization_id, verbose = true)
        new(category_name, organization_id, verbose).call
      end

      def call
        archive_initiatives
      end

      private

      def archive_initiatives
        Rails.logger.info "Initiatives to archived: #{initiatives.count}" if @verbose

        # rubocop:disable Rails/SkipsModelValidations
        initiatives.update_all(decidim_initiatives_archive_categories_id: @category.id)
        # rubocop:enable Rails/SkipsModelValidations

        Rails.logger.info "Finished..." if @verbose
      end

      def find_or_create_category(category_name)
        Decidim::InitiativesArchiveCategory.find_or_create_by!(name: category_name, organization: @organization)
      end

      def find_organization(organization_id)
        Decidim::Organization.find(organization_id)
      end

      def initiatives
        Decidim::Initiative.where(organization: @organization).not_archived
      end
    end
  end
end
