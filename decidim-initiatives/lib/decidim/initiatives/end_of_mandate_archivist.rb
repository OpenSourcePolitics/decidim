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
        new(category_name, organization_id, verbose)
      end

      def call
        delete_authorizations
        delete_authors
        archive_initiatives
      end

      private

      def delete_authors
        Rails.logger.info "Authors to be deleted: #{users.count}" if @verbose

        users.each do |author|
          DestroyAccount.call(author, Decidim::DeleteAccountForm.from_params({}))
        end

        Rails.logger.info "Finished..." if @verbose
      end

      def delete_authorizations
        Rails.logger.info "Authorizations to be deleted: #{users.count}" if @verbose

        # rubocop:disable Rails/SkipsModelValidations
        authorizations.update_all(encrypted_metadata: nil)
        # rubocop:enable Rails/SkipsModelValidations

        Rails.logger.info "Finished..." if @verbose
      end

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
        Decidim::Initiative.where(organization: @organization).includes(:committee_members).not_archived
      end

      def initiatives_authors_ids
        initiatives.map(&:decidim_author_id)
      end

      def committee_members_ids
        initiatives.flat_map(&:committee_members).collect(&:decidim_users_id)
      end

      def users
        Decidim::User.where(id: (committee_members_ids + initiatives_authors_ids).uniq)
      end

      def authorizations
        Decidim::Authorization.where(user: users)
      end
    end
  end
end
