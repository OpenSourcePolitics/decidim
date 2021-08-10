# frozen_string_literal: true

module Decidim
  module Admin
    class PseudomizeComponent < Rectify::Command
      def initialize(user, component)
        @component = component
        @user = user
      end

      def call
        @component.manifest.run_hooks(:pseudomize, @component)

        status_manager.mark_as_running
        Decidim::PseudomizeResourcesGeneratorJob.perform_later(@user, @component)

        broadcast(:ok)
      end

      private

      def status_manager
        @status_manager ||= Decidim::PseudomizeResourcesStatusManager.new(@component)
      end
    end
  end
end
