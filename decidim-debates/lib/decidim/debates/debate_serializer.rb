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
          translated_column_name(:id, "decidim.debates.admin.exports.column_name.debates") => debate.id,
          translated_column_name(:title, "decidim.debates.admin.exports.column_name.debates") => present(debate).title,
          translated_column_name(:description, "decidim.debates.admin.exports.column_name.debates") => present(debate).description,
          translated_column_name(:comments, "decidim.debates.admin.exports.column_name.debates") => debate.comments.count,
          translated_column_name(:url, "decidim.debates.admin.exports.column_name.debates") => url,
          translated_column_name(:category, "decidim.debates.admin.exports.column_name.debates.category") => {
            translated_column_name(:id, "decidim.debates.admin.exports.column_name.debates.category") => debate.category.try(:id),
            translated_column_name(:name, "decidim.debates.admin.exports.column_name.debates.category") => debate.category.try(:name) || empty_translatable
          },
          translated_column_name(:component, "decidim.debates.admin.exports.column_name.debates.component") => {
            translated_column_name(:id, "decidim.debates.admin.exports.column_name.debates.component") => component.id
          },
          translated_column_name(:participatory_space, "decidim.debates.admin.exports.column_name.debates.participatory_space") => {
            translated_column_name(:id, "decidim.debates.admin.exports.column_name.debates.participatory_space") => debate.participatory_space.id,
            translated_column_name(:url, "decidim.debates.admin.exports.column_name.debates.participatory_space") =>
              Decidim::ResourceLocatorPresenter.new(debate.participatory_space).url
          },
          translated_column_name(:created_at, "decidim.debates.admin.exports.column_name.debates") => debate.created_at,
          translated_column_name(:start_time, "decidim.debates.admin.exports.column_name.debates") => debate.start_time,
          translated_column_name(:end_time, "decidim.debates.admin.exports.column_name.debates") => debate.end_time,
          translated_column_name(:author_url, "decidim.debates.admin.exports.column_name.debates") => Decidim::UserPresenter.new(debate.author).try(:profile_url)
        }.merge(options_merge(admin_extra_fields))
      end

      private

      attr_reader :debate

      def admin_extra_fields
        {
          translated_column_name(:user, "decidim.debates.admin.exports.column_name.debates.user") => extract_author_data do
            {
              translated_column_name(:name, "decidim.debates.admin.exports.column_name.debates.user") => debate.author.try(:name),
              translated_column_name(:nickname, "decidim.debates.admin.exports.column_name.debates.user") => debate.author.try(:nickname),
              translated_column_name(:email, "decidim.debates.admin.exports.column_name.debates.user") => debate.author.try(:email),
              translated_column_name(:registration_metadata, "decidim.debates.admin.exports.column_name.debates.user") => debate.author.try(:registration_metadata)
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
            translated_column_name(:name, "decidim.debates.admin.exports.column_name.debates.user") => "",
            translated_column_name(:nickname, "decidim.debates.admin.exports.column_name.debates.user") => "",
            translated_column_name(:email, "decidim.debates.admin.exports.column_name.debates.user") => "",
            translated_column_name(:registration_metadata, "decidim.debates.admin.exports.column_name.debates.user") => ""
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
    end
  end
end
