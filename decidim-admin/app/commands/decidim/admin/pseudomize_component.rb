# frozen_string_literal: true

module Decidim
  module Admin
    class PseudomizeComponent < Rectify::Command
      def initialize(component)
        @component = component
      end

      def call
        Decidim::PseudomizeResourcesGeneratorJob.perform_later(@component)
      end
    end
  end
end
