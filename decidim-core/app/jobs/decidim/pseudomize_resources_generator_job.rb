# frozen_string_literal: true

module Decidim
  class PseudomizeResourcesGeneratorJob < ApplicationJob
    queue_as :default

    def perform(component)
      resources(component).each do |resource|
        Decidim::PseudomizeResourceAuthorsJob.perform_later(resource)
      end
    end

    private

    def resources(component)
      resources = resources_for(component)
      comments_for(resources).each { |comment| resources << comment }

      resources
    end

    def resources_for(component)
      resources_classes.flat_map { |klass| klass.constantize.where(component: component).to_a }
    end

    def resources_classes
      Decidim.resource_registry
             .manifests
             .map(&:model_class_name)
             .select { |resource| resource.constantize.column_names.include? "decidim_component_id" }
    end

    def comments_for(resources)
      Decidim::Comments::Comment.where(commentable: resources).to_a
    end
  end
end
