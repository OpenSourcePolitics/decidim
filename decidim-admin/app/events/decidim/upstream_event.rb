# frozen_string_literal: true

require "mustache"

module Decidim
  class UpstreamEvent < Decidim::Events::SimpleEvent
    include Decidim::Events::AuthorEvent

    i18n_attributes :user_name, :user_nickname
    i18n_attributes :participatory_space_slug, :participatory_space_id
    i18n_attributes :manage_resource_url, :manage_moderation_url

    def event_has_roles?
      true
    end

    def user_name
      user.try(:name)
    end

    def user_nickname
      user.try(:nickname)
    end

    def participatory_space_slug
      participatory_space.try(:slug)
    end

    def participatory_space_id
      participatory_space.try(:id)
    end

    def manage_resource_url
      return manage_moderation_url if resource.is_a?(Decidim::Comments::Comment)
      return manage_moderation_url unless participatory_space.admins.include? @user
      manage_component_url(component)
    end

    def manage_moderation_url
      EngineRouter.admin_proxy(participatory_space).upstream_moderations_url(host: component.organization.host)
    end

    # Caches the path for the given resource when it's a Decidim::Component.
    def resource_path
      return super unless resource.is_a?(Decidim::Comments::Comment)

      @resource_path ||= Decidim::ResourceLocatorPresenter.new(resource.root_commentable).path(url_params)
    end

    # Caches the URL for the given resource when it's a Decidim::Component.
    def resource_url
      return super unless resource.is_a?(Decidim::Comments::Comment)

      @resource_url ||= Decidim::ResourceLocatorPresenter.new(resource.root_commentable).url(url_params)
    end

    def resource_title
      return super unless resource.is_a?(Decidim::Comments::Comment)

      if resource.root_commentable.respond_to?(:title)
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(translated_attribute(resource.root_commentable.title))
        renderer.render(links: false)
      elsif resource.root_commentable.respond_to?(:name)
        translated_attribute(resource.root_commentable.name)
      end
    end

    def resource_text
      renderer = Decidim::ContentRenderers::HashtagRenderer.new(resource.body)
      renderer.render(links: false)
    end

    def url_params
      { anchor: "comment_#{resource.id}" }
    end

    private

    def default_i18n_options
      {
        user_name: user_name,
        user_pseudo: user_nickname,
        resource_path: resource_path,
        resource_title: resource_title,
        resource_url: resource_url,
        participatory_space_title: participatory_space_title,
        participatory_space_url: participatory_space_url,
        participatory_space_slug: participatory_space_url,
        participatory_space_id: participatory_space_url,
        manage_resource_url: manage_resource_url,
        manage_moderation_url: manage_moderation_url,
        scope: i18n_scope
      }
    end
  end
end
