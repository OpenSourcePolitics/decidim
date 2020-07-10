# frozen_string_literal: true

module Decidim
  module Initiatives
    # This cell renders the Medium (:m) initiative card
    # for an given instance of an Initiative
    class InitiativeMCell < Decidim::CardMCell
      include InitiativeHelper
      include Decidim::Initiatives::Engine.routes.url_helpers

      cache :show do
        Digest::MD5.hexdigest(cache_hash)
      end

      property :state

      private

      def cache_hash
        hash = model.author.cache_version +
               model.cache_version +
               model.supports_count.to_s +
               comments_count.to_s

        hash << current_user.follows?(model).to_s if current_user

        hash
      end

      def translatable?
        true
      end

      def title
        decidim_html_escape(translated_attribute(model.title))
      end

      def hashtag
        decidim_html_escape(model.hashtag)
      end

      def has_state?
        true
      end

      # Explicitely commenting the used I18n keys so their are not flagged as unused
      # i18n-tasks-use t('decidim.initiatives.show.badge_name.accepted')
      # i18n-tasks-use t('decidim.initiatives.show.badge_name.created')
      # i18n-tasks-use t('decidim.initiatives.show.badge_name.discarded')
      # i18n-tasks-use t('decidim.initiatives.show.badge_name.published')
      # i18n-tasks-use t('decidim.initiatives.show.badge_name.rejected')
      # i18n-tasks-use t('decidim.initiatives.show.badge_name.validating')
      def badge_name
        I18n.t(model.state, scope: "decidim.initiatives.show.badge_name")
      end

      def state_classes
        case state
        when "accepted", "published", "debatted"
          ["success"]
        when "rejected", "discarded", "classified"
          ["alert"]
        when "validating", "examinated"
          ["warning"]
        else
          ["muted"]
        end
      end

      def has_area_color?
        model.area_color.present?
      end

      def area_color_style
        "style=\"background-color:#{model.area_color};\""
      end

      def area_logo
        model.area_logo
      end

      def area_name
        translated_attribute(model.area_name)
      end

      def resource_path
        initiative_path(model)
      end

      def resource_icon
        icon "initiatives", class: "icon--big"
      end

      def authors
        [present(model).author] +
          model.committee_members.approved.non_deleted.excluding_author.map { |member| present(member.user) }
      end

      def comments_count
        return 0 unless model.type.comments_enabled
        return model.comments.not_hidden.count if model.comments.respond_to? :not_hidden

        model.comments.count
      end

      def comments_count_status
        return unless model.type.comments_enabled
        return render_comments_count unless has_link_to_resource?

        link_to resource_path do
          render_comments_count
        end
      end
    end
  end
end
