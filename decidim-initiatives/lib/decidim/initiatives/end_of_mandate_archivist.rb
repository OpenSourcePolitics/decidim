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
        ActiveRecord::Base.transaction do
          delete_authorizations
          delete_authors
          delete_logs
          archive_initiatives
        end
      end

      private

      def delete_authors
        Rails.logger.info "Authors to be deleted: #{users.count}" if @verbose

        users.each do |author|
          DestroyAccount.call(author, Decidim::DeleteAccountForm.from_params({}))
        end

        Rails.logger.info "Finished..." if @verbose
      end

      def delete_logs
        Rails.logger.info "Logs to be deleted: #{logs.count}" if @verbose

        logs.delete_all

        Rails.logger.info "Finished..." if @verbose
      end

      def delete_authorizations
        Rails.logger.info "Authorizations to be deleted: #{users.count}" if @verbose

        authorizations.destroy_all

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
        @initiatives ||= Decidim::Initiative.where(organization: @organization).includes(:committee_members).not_archived
      end

      def users
        @users ||= Decidim::User.where(organization: @organization).where.not(admin: true)
      end

      def authorizations
        @authorizations ||= Decidim::Authorization.where(user: users)
      end

      def logs
        @logs ||= Decidim::ActionLog.where(organization: @organization)
      end
    end
  end
end
