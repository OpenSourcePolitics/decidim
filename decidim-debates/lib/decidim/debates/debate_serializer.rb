# frozen_string_literal: true

module Decidim
  module Debates
    # This class serializes a debate so can be exported to CSV, JSON or other
    # formats.
    class DebateSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a debate.
      def initialize(debate, private_scope = false)
        @debate = debate
        @private_scope = private_scope
      end

      # Public: Exports a hash with the serialized data for this debate.
      def serialize
        {
          t_column_name(:id) => debate.id,
          t_column_name(:title) => present(debate).title,
          t_column_name(:description) => present(debate).description,
          t_column_name(:comments) => debate.comments.count,
          t_column_name(:url) => url,
          t_column_name(:category, ".category") => {
            t_column_name(:id, ".category") => debate.category.try(:id),
            t_column_name(:name, ".category") => debate.category.try(:name) || empty_translatable
          },
          t_column_name(:component, ".component") => {
            t_column_name(:id, ".component") => component.id
          },
          t_column_name(:participatory_space, ".participatory_space") => {
            t_column_name(:id, ".participatory_space") => debate.participatory_space.id,
            t_column_name(:url, ".participatory_space") =>
              Decidim::ResourceLocatorPresenter.new(debate.participatory_space).url
          },
          t_column_name(:created_at) => debate.created_at,
          t_column_name(:start_time) => debate.start_time,
          t_column_name(:end_time) => debate.end_time,
          t_column_name(:author_url) => Decidim::UserPresenter.new(debate.author).try(:profile_url)
        }.merge(options_merge(admin_extra_fields))
      end

      private

      attr_reader :debate

      def admin_extra_fields
        {
          t_column_name(:user, ".user") => extract_author_data do
            {
              t_column_name(:name, ".user") => debate.author.try(:name),
              t_column_name(:nickname, ".user") => debate.author.try(:nickname),
              t_column_name(:email, ".user") => debate.author.try(:email),
              t_column_name(:birth_date, ".user") => key_from_registration_metadata(debate.author, :birth_date).to_s,
              t_column_name(:gender, ".user") => key_from_registration_metadata(debate.author, :gender),
              t_column_name(:work_area, ".user") => key_from_registration_metadata(debate.author, :work_area),
              t_column_name(:residential_area, ".user") => key_from_registration_metadata(debate.author, :residential_area),
              t_column_name(:statutory_representative_email, ".user") => key_from_registration_metadata(debate.author, :statutory_representative_email),
            }
          end
        }
      end

      # Private: Returns the Hash block given if the proposal creator is a User
      #
      # Returns: Hash block or Hash with keys / empty values
      def extract_author_data
        if debate.author.is_a?(Decidim::Organization) || debate.author.is_a?(Decidim::UserGroup) || !block_given?
          {
            t_column_name(:name, ".user") => "",
            t_column_name(:nickname, ".user") => "",
            t_column_name(:email, ".user") => "",
            t_column_name(:birth_date, ".user") => "",
            t_column_name(:gender, ".user") => "",
            t_column_name(:work_area, ".user") => "",
            t_column_name(:residential_area, ".user") => "",
            t_column_name(:statutory_representative_email, ".user") => ""
          }
        else
          yield
        end
      end

      def component
        debate.component
      end

      def url
        Decidim::ResourceLocatorPresenter.new(debate).url
      end

      def i18n_scope
        "decidim.debates.admin.exports.column_name.debates"
      end
    end
  end
end
