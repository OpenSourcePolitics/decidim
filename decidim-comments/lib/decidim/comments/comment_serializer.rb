# frozen_string_literal: true

module Decidim
  module Comments
    class CommentSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Serializes a comment
      def serialize
        common = {
          id: resource.id,
          created_at: resource.created_at,
          body: resource.body,
          author: {
            id: resource.author.id,
            name: resource.author.name
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

        return common unless resource.upstream_moderation_activated?

        common.merge(
          upstream_status: upstream_status
        )
      end

      private

      def upstream_status
        if resource.upstream_pending?
          I18n.t("pending_moderation", scope: "decidim.upstream_moderations.actions")
        elsif resource.upstream_hidden?
          I18n.t("not_visible", scope: "decidim.upstream_moderations.actions")
        else
          I18n.t("visible", scope: "decidim.upstream_moderations.actions")
        end
      end

      def root_commentable_url
        @root_commentable_url ||= Decidim::ResourceLocatorPresenter.new(resource.root_commentable).url
      end
    end
  end
end
