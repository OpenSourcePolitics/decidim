# frozen-string_literal: true

module Decidim
  module Comments
    class ReplyCreatedEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::AuthorEvent

      delegate :author, to: :comment

      def resource_path
        resource_locator.path(url_params)
      end

      def resource_url
        resource_locator.url(url_params)
      end

      def resource_text
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(comment.body)
        renderer.render
      end

      private

      def comment
        @comment ||= Decidim::Comments::Comment.find(extra[:comment_id])
      end

      def url_params
        { anchor: "comment_#{comment.id}" }
      end
    end
  end
end
