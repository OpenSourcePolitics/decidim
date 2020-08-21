# frozen_string_literal: true

module Decidim
  # Initiative type.
  class InitiativesType < ApplicationRecord
    include Decidim::HasResourcePermission

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    has_many :scopes,
             foreign_key: "decidim_initiatives_types_id",
             class_name: "Decidim::InitiativesTypeScope",
             dependent: :destroy,
             inverse_of: :type

    has_many :initiatives,
             through: :scopes,
             class_name: "Decidim::Initiative"

    enum signature_type: [:online, :offline, :any], _suffix: true

    validates :signature_type, presence: true
    validates :title, :description, presence: true

    mount_uploader :banner_image, Decidim::BannerImageUploader

    before_update :update_global_scope, if: :missing_global_scope?

    def allowed_signature_types_for_initiatives
      return %w(online offline any) if any_signature_type?

      Array(signature_type.to_s)
    end

    def allow_resource_permissions?
      true
    end

    def mounted_admin_engine
      "decidim_admin_initiatives"
    end

    def mounted_params
      { host: organization.host }
    end

    private

    def missing_global_scope?
      only_global_scope_enabled? && scopes.present? && !scopes.include?(nil)
    end

    def update_global_scope
      total_required = scopes.sum(&:supports_required)
      InitiativesTypeScope.new(
        supports_required: total_required,
        decidim_scopes_id: nil,
        decidim_initiatives_types_id: id
      ).save
    end
  end
end
