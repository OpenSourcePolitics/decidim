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
      def search_state
        states
      end

      # Handle the custom state filter
      def search_custom_state
        states
      end

      def search_type_id
        return query if type_ids.include?("all")

        types = InitiativesTypeScope.where(decidim_initiatives_types_id: type_ids).pluck(:id)

        query.where(scoped_type: types)
      end

      def search_author
        if author == "myself" && options[:current_user]
          co_authoring_initiative_ids = Decidim::InitiativesCommitteeMember.where(
            decidim_users_id: options[:current_user].id
          ).pluck(:decidim_initiatives_id)

          query.where(decidim_author_id: options[:current_user].id, decidim_author_type: Decidim::UserBaseEntity.name)
               .or(query.where(id: co_authoring_initiative_ids))
               .unscope(where: :published_at)
        else
          query.where.not(state: [:created, :validating])
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

      def search_area_id
        return query if area_ids.include?("all")

        query.where(decidim_area_id: area_ids)
      end

      private

      def query_for_specific_state(query, state, status = {})
        query_for_state = query.where(id: state)

        if status[:published] || status[:examinated] || status[:classified] || status[:debatted]
          query_for_state = query_for_state.where(id: status[:classified])
                                           .or(query_for_state.where(id: status[:examinated]))
                                           .or(query_for_state.where(id: status[:published]))
                                           .or(query_for_state.where(id: status[:debatted]))
        end

        query_for_state
      end

      # search_state and search_custom_state should be a common query in different filter
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def states
        accepted ||= query.accepted if state&.member?("accepted") || state.nil?
        rejected ||= query.rejected if state&.member?("rejected") || state.nil?
        open ||= query.open if state&.member?("open") || state.nil?
        closed ||= query.closed if state&.member?("closed") || state.nil?
        answered ||= query.answered if state&.member?("answered") || state.nil?
        custom_states = {
          published: custom_state&.member?("published") ? query.with_state(:published) : nil,
          examinated: custom_state&.member?("examinated") ? query.examinated : nil,
          classified: custom_state&.member?("classified") ? query.classified : nil,
          debatted: custom_state&.member?("debatted") ? query.debatted : nil
        }

        query_for_state = query_for_specific_state(query, accepted, custom_states) if accepted.present?

        if rejected.present?
          query_for_state = if query_for_state.present?
                              query_for_state.or(query_for_specific_state(query, rejected, custom_states))
                            else
                              query_for_specific_state(query, rejected, custom_states)
                            end
        end

        if open.present?
          query_for_state = if query_for_state.present?
                              query_for_state.or(query_for_specific_state(query, open, custom_states))
                            else
                              query_for_specific_state(query, open, custom_states)
                            end
        end

        if closed.present?
          query_for_state = if query_for_state.present?
                              query_for_state.or(query_for_specific_state(query, closed, custom_states))
                            else
                              query_for_specific_state(query, closed, custom_states)
                            end
        end

        if answered.present?
          query_for_state = if query_for_state.present?
                              query_for_state.or(query_for_specific_state(query, answered, custom_states))
                            else
                              query_for_specific_state(query, answered, custom_states)
                            end
        end

        query_for_state || query.where(id: nil)
      end

      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      # Private: Returns an array with checked type ids.
      def type_ids
        [type_id].flatten
      end

      # Private: Returns an array with checked scope ids.
      def scope_ids
        [scope_id].flatten
      end

      # Private: Returns an array with checked area ids, handling area_types which are coded as its
      # areas ids joined by _.
      def area_ids
        return [area_id] if area_id.is_a? String

        area_id.map { |id| id.split("_") }.flatten.uniq
      end
    end
  end
end
