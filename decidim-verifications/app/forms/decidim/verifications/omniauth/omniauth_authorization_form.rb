# frozen_string_literal: true

module Decidim
  module Verifications
    module Omniauth
      class OmniauthAuthorizationForm < AuthorizationHandler
        attribute :provider, String
        attribute :oauth_data, Hash

        validate :has_identity?
        validate :check_anti_affinity?

        def metadata
          super.merge(provider: provider).merge(oauth_data)
        end

        def unique_id
          identity_for_user&.uid
        end

        def form_attributes
          super - [:provider, :oauth_data]
        end

        def to_partial_path
          handler_name.sub!(/_form$/, "") + "/form"
        end

        private

        def manifest
          @manifest ||= Decidim::Verifications.find_workflow_manifest(provider)
        end

        def has_identity?
          identity_for_user&.present?
        end

        def check_anti_affinity?
          return true unless manifest.present?
          return true unless manifest.anti_affinity&.present?

          anti_affinity_names = (manifest.anti_affinity & identities_for_user.pluck(:provider))
          return true unless anti_affinity_names.any?

          anti_affinity_labels = (anti_affinity_names << provider.to_s).map do |handler|
            I18n.t("#{handler}.name", scope: "decidim.authorization_handlers")
          end.join(" / ")

          errors.add(:anti_affinity, I18n.t("decidim.verifications.omniauth.errors.anti_affinity", anti_affinity: anti_affinity_labels, locale: user.locale))
          false
        end

        def organization
          current_organization || user.organization
        end

        def identity_for_user
          @identity_for_user ||= Decidim::Identity.find_by(organization: organization, user: user, provider: provider)
        end

        def identities_for_user
          @identities_for_user ||= Decidim::Identity.where(organization: organization, user: user)
        end

        def _clean_hash(data)
          data.delete_if { |_k, v| v.is_a?(Hash) ? _clean_hash(v).blank? : v.blank? }
        end
      end
    end
  end
end
