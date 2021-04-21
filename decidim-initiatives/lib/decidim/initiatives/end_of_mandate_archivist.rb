module Decidim
  module Initiatives
    class EndOfMandateArchivist
      def initialize(category_name, organization_id)
        @organization ||= find_organization(organization_id)
        @category ||= find_or_create_category(category_name)
      end

      def self.archive(category_name, organization_id, verbose = true)
        self.new(category_name, organization_id).call(verbose)
      end

      def call(verbose)
        puts "Initiatives to archived: #{initiatives.count}" if verbose
        initiatives.update_all(decidim_initiatives_archive_categories_id: @category.id)
        puts "Finished..." if verbose
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
