# frozen_string_literal: true

module Decidim
  module Admin
    class PseudomizeComponent < Rectify::Command
      def initialize(user, component)
        @component = component
        @user = user
      end

      def call
        Decidim::PseudomizeResourcesGeneratorJob.perform_later(@user, @component)

        broadcast(:ok)
      end
    end
  end
end
