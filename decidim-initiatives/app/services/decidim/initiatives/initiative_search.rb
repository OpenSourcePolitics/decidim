# frozen_string_literal: true

module Decidim
  module Initiatives
    # Service that encapsulates all logic related to filtering initiatives.
    class InitiativeSearch < Searchlight::Search
      include CurrentLocale

      # Public: Initializes the service.
      # page        - The page number to paginate the results.
      # per_page    - The number of proposals to return per page.
      def initialize(options = {})
        super(options)
      end

      def base_query
        Decidim::Initiative
          .includes(scoped_type: [:scope])
          .joins("JOIN decidim_users ON decidim_users.id = decidim_initiatives.decidim_author_id")
          .where(organization: options[:organization])
          .where.not(state: [:created, :validating])
          .where.not(published_at: nil)
      end

      # Handle the search_text filter
      def search_search_text
        query
          .where("title->>'#{current_locale}' ILIKE ?", "%#{search_text}%")
          .or(
            query.where(
              "description->>'#{current_locale}' ILIKE ?",
              "%#{search_text}%"
            )
          )
          .or(
            query.where(
              "cast(decidim_initiatives.id as text) ILIKE ?", "%#{search_text}%"
            )
          )
          .or(
            query.where(
              "decidim_users.name ILIKE ? OR decidim_users.nickname ILIKE ?", "%#{search_text}%", "%#{search_text}%"
            )
          )
      end

      # Handle the state filter
      # rubocop:disable Metrics/CyclomaticComplexity
      def search_state
        accepted ||= query.accepted if state.member?("accepted")
        rejected ||= query.rejected if state.member?("rejected")
        open ||= query.open if state.member?("open")
        closed ||= query.closed if state.member?("closed")
        answered ||= query.answered if state.member?("answered")
        published ||= query.published if state.member?("published")
        classified ||= query.classified if state.member?("classified")
        examinated ||= query.examinated if state.member?("examinated")
        debatted ||= query.debatted if state.member?("debatted")

        query
          .where(id: accepted)
          .or(query.where(id: rejected))
          .or(query.where(id: answered))
          .or(query.where(id: open))
          .or(query.where(id: closed))
          .or(query.where(id: published))
          .or(query.where(id: classified))
          .or(query.where(id: examinated))
          .or(query.where(id: debatted))
      end

      # rubocop:enable Metrics/CyclomaticComplexity
      def search_type_id
        return query if type_ids.include?("all")

        types = InitiativesTypeScope.where(decidim_initiatives_types_id: type_ids).pluck(:id)

        query.where(scoped_type: types)
      end

      def search_author
        if author == "myself" && options[:current_user]
          query.where(decidim_author_id: options[:current_user].id)
        else
          query
        end
      end

      def search_scope_id
        return query if scope_ids.include?("all")

        clean_scope_ids = scope_ids
        conditions = []
        conditions << "decidim_initiatives_type_scopes.decidim_scopes_id IS NULL" if clean_scope_ids.delete("global")
        conditions.concat(["? = ANY(decidim_scopes.part_of)"] * clean_scope_ids.count) if clean_scope_ids.any?

        query.joins(:scoped_type).references(:decidim_scopes).where(conditions.join(" OR "), *clean_scope_ids.map(&:to_i))
      end

      private

      # Private: Returns an array with checked type ids.
      def type_ids
        [type_id].flatten
      end

      # Private: Returns an array with checked scope ids.
      def scope_ids
        [scope_id].flatten
      end
    end
  end
end
