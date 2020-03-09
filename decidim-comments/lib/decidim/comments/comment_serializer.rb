# frozen_string_literal: true

module Decidim
  module Comments
    class CommentSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Serializes a comment
      def serialize
        {
          translated_column_name(:id, "decidim.comments.exports.column_name.comments") => resource.id,
          translated_column_name(:created_at, "decidim.comments.exports.column_name.comments") => resource.created_at,
          translated_column_name(:body, "decidim.comments.exports.column_name.comments") => resource.body,
          translated_column_name(:author, "decidim.comments.exports.column_name.comments.author") => {
            translated_column_name(:id, "decidim.comments.exports.column_name.comments.author") => resource.author.id,
            translated_column_name(:name, "decidim.comments.exports.column_name.comments.author") => resource.author.name,
            translated_column_name(:registration_metadata, "decidim.comments.exports.column_name.comments.author") => resource.author.registration_metadata
          },
          translated_column_name(:alignment, "decidim.comments.exports.column_name.comments") => resource.alignment,
          translated_column_name(:depth, "decidim.comments.exports.column_name.comments") => resource.depth,
          translated_column_name(:user_group, "decidim.comments.exports.column_name.comments.user_group") => {
            translated_column_name(:id, "decidim.comments.exports.column_name.comments.user_group") => resource.user_group.try(:id),
            translated_column_name(:name, "decidim.comments.exports.column_name.comments.user_group") => resource.user_group.try(:name) || empty_translatable
          },
          translated_column_name(:commentable_id, "decidim.comments.exports.column_name.comments") => resource.decidim_commentable_id,
          translated_column_name(:commentable_type, "decidim.comments.exports.column_name.comments") => resource.decidim_commentable_type,
          translated_column_name(:root_commentable_url, "decidim.comments.exports.column_name.comments") => root_commentable_url
        }
      end

      private

      def root_commentable_url
        @root_commentable_url ||= Decidim::ResourceLocatorPresenter.new(resource.root_commentable).url
      end
    end
  end
end
