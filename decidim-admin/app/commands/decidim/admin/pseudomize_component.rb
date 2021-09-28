# frozen_string_literal: true

module Decidim
  module Admin
    class PseudomizeComponent < Rectify::Command
      def initialize(user, component)
        @component = component
        @user = user
      end

      def call
        @component.manifest.run_hooks(:pseudomize, @component)

        Decidim.traceability.perform_action!(
          :pseudomize,
          @component,
          @user,
          visibility: "all"
        ) do
          resources = all_resources_for(@component)
          status_manager.mark_as_running(resources.count)
          Decidim::PseudomizeResourcesGeneratorJob.perform_later(@user, @component, resources)
        end

        broadcast(:ok)
      end

      private

      def status_manager
        @status_manager ||= Decidim::PseudomizeResourcesStatusManager.new(@component)
      end

      def all_resources_for(component)
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
        top_comments = find_comments_for(resources)

        dig_comments(top_comments)
      end

      def find_comments_for(resources)
        Decidim::Comments::Comment.where(commentable: resources).to_a
      end

      def dig_comments(resources, total = [])
        return total.uniq.compact if resources.blank?

        new_comments = find_comments_for(resources)

        dig_comments(new_comments, (total.uniq + resources + new_comments))
      end
    end
  end
end
