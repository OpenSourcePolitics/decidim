# frozen_string_literal: true

module Decidim
  class PseudomizeResourcesGeneratorJob < ApplicationJob
    queue_as :default

    def perform(user, component)
      resources = resources(component)
      cache_entry = "pseudomize_resources_#{component.manifest_name}"

      write_to_cache(cache_entry, resources)

      resources.each do |resource|
        Decidim::PseudomizeResourceAuthorsJob.perform_later(resource, cache_entry)
      end

      Decidim::EndOfPseudomizeResourcesTaskJob.perform_later(user, cache_entry)
    end

    private

    def resources(component)
      resources = resources_for(component)
      comments_for(resources).each { |comment| resources << comment }

      resources
    end

    def resources_for(component)
      resources_class(component).constantize.where(component: component).to_a
    end

    def resources_class(component)
      Decidim.find_resource_manifest(component.manifest_name)&.model_class_name
    end

    def comments_for(resources)
      Decidim::Comments::Comment.where(commentable: resources).to_a
    end

    def write_to_cache(cache_entry, resources)
      Rails.cache.write(cache_entry, total: resources.count, current: 0)
    end
  end
end
