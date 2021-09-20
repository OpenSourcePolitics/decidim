# frozen_string_literal: true

module Decidim
  class PseudomizeResourcesGeneratorJob < ApplicationJob
    queue_as :default

    def perform(user, component)
      resources = resources(component)
      status_manager.write(total: resources.count, current: 0)

      resources.each do |resource|
        Decidim::PseudomizeResourceAuthorsJob.perform_later(resource, component)
      end

      Decidim::EndOfPseudomizeResourcesTaskJob.perform_later(user, component)
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
      top_comments = Decidim::Comments::Comment.where(commentable: resources).to_a
      sub_comments = Decidim::Comments::Comment.where(commentable: top_comments).to_a

      (top_comments + sub_comments).uniq
    end

    def status_manager
      @status_manager ||= Decidim::PseudomizeResourcesStatusManager.new(arguments.last)
    end
  end
end
