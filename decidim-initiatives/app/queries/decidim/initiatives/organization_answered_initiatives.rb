# frozen_string_literal: true

module Decidim
  module Initiatives
    # This query retrieves the organization prioritized initiatives that will appear in the homepage
    class OrganizationAnsweredInitiatives < Rectify::Query
      attr_reader :organization

      def initialize(organization)
        @organization = organization
      end

      def query
        Decidim::Initiative.where(organization: organization)
                           .with_states(states)
                           .published
                           .order_by_answer_date
      end

      private

      def states
        [:classified, :examinated, :debatted]
      end
    end
  end
end
