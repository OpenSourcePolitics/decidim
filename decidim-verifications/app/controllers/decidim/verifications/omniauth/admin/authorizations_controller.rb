# frozen_string_literal: true

module Decidim
  module Verifications
    module Omniauth
      module Admin
        class AuthorizationsController < Decidim::Admin::ApplicationController
          layout "decidim/admin/users"

          helper Decidim::Verifications::MetadataHelper

          helper_method :handler_name

          def index
            enforce_permission_to :index, :authorization
            @authorizations = collection.page(params[:page]).per(15)
          end

          def metadata
            @metadata ||= current_authorization.metadata
            render template: "decidim/verifications/metadata/show"
          end

          private

          def handler_name
            @handler_name ||= url_options[:script_name].split("/").last
          end

          def current_authorization
            @current_authorization ||= collection.find(params[:id])
          end

          def collection
            @collection ||= Authorizations.new(organization: current_organization, name: handler_name).query
          end
        end
      end
    end
  end
end
