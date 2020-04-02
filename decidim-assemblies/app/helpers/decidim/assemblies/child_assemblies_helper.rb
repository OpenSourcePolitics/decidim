# frozen_string_literal: true

module Decidim
  module Assemblies
    # Helpers related to the Assemblies children.
    module ChildAssembliesHelper
      # Allows to sort the child assemblies by column if needed.
      # Returns : ActiveRecord::AssociationRelation of Assemblies or empty
      def child_assemblies_collection(current_participatory_space, sorted_by = nil)
        current_participatory_space.children.published unless current_participatory_space.sort_children?
        current_participatory_space.children.published.sort_children_by(sorted_by)
      end
    end
  end
end
