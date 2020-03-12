# frozen_string_literal: true

module Decidim
  module Comments
    class CommentSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Serializes a comment
      def serialize
        {
          id: resource.id,
          created_at: resource.created_at,
          body: resource.body,
          author: {
            id: resource.author.id,
            name: resource.author.name,
            birth_date: key_from_registration_metadata(resource.author, :birth_date).to_s,
            gender: key_from_registration_metadata(resource.author, :gender),
            work_area: key_from_registration_metadata(resource.author, :work_area),
            residential_area: key_from_registration_metadata(resource.author, :residential_area),
            statutory_representative_email: key_from_registration_metadata(resource.author, :statutory_representative_email)
          },
          alignment: resource.alignment,
          depth: resource.depth,
          user_group: {
            id: resource.user_group.try(:id),
            name: resource.user_group.try(:name) || empty_translatable
          },
          commentable_id: resource.decidim_commentable_id,
          commentable_type: resource.decidim_commentable_type,
          root_commentable_url: root_commentable_url
        }
      end

      private

      def root_commentable_url
        @root_commentable_url ||= Decidim::ResourceLocatorPresenter.new(resource.root_commentable).url
      end
    end
  end
end
