# frozen_string_literal: true

module Decidim
  module Admin
    class PseudomizeComponent < Rectify::Command
      def initialize(user, component)
        @component = component
        @user = user
      end

      def call
        # close__contribution
        # close_comments

        cache_manager.mark_as_running
        Decidim::PseudomizeResourcesGeneratorJob.perform_later(@user, @component)

        broadcast(:ok)
      end

      private

      def cache_manager
        @cache_manager ||= Decidim::PseudomizeResourcesCacheManager.new(@component)
      end
    end
  end
end
