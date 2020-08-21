# frozen_string_literal: true

module Decidim
  module Verifications
    module Omniauth
      module Admin
        class MetadataController < Decidim::Admin::ApplicationController
          layout false
          helper Decidim::Verifications::MetadataHelper
          helper_method :handler_name, :target_user

          def show
            @metadata ||= current_authorization.metadata
            @user ||= current_authorization.user
            render template: "decidim/verifications/metadata/show"
          end

          private

          def handler_name
            @handler_name ||= url_options[:script_name].split("/").last
          end

          def current_authorization
            @current_authorization ||= Decidim::Authorization.find(params[:id])
          end
        end
      end
    end
  end
end
