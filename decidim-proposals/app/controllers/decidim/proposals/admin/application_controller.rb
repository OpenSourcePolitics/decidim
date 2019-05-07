# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Admin::Components::BaseController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::Admin::Components::BaseController
        helper Decidim::ApplicationHelper
        helper_method :merge_query, :drop_query

        def merge_query(options = {})
          return options unless params["q"]
          params["q"].to_unsafe_h.merge(options)
        end

        def drop_query(param = "")
          return params["q"] if param.blank?
          params["q"].to_unsafe_h.except(param)
        end
      end
    end
  end
end
