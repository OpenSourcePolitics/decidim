# frozen_string_literal: true

module Decidim
  module Initiatives
    # This controller provides a widget that allows embedding the initiative
    class InitiativeWidgetsController < Decidim::WidgetsController
      helper InitiativesHelper
      helper PaginateHelper
      helper InitiativeHelper
      helper Decidim::Comments::CommentsHelper
      helper Decidim::Admin::IconLinkHelper

      include NeedsInitiative

      def show
        redirect_to "/404" unless visible?

        super
      end

      private

      def visible?
        current_initiative.published? || current_initiative.accepted? || current_initiative.rejected?
      end

      def model
        @model ||= current_initiative
      end

      def current_participatory_space
        model
      end

      def iframe_url
        @iframe_url ||= initiative_initiative_widget_url(model)
      end
    end
  end
end
