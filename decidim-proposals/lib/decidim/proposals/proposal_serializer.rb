# frozen_string_literal: true

module Decidim
  module Proposals
    # This class serializes a Proposal so can be exported to CSV, JSON or other
    # formats.
    class ProposalSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a proposal.
      def initialize(proposal, private_scope = false)
        @proposal = proposal
        @private_scope = private_scope
      end

      # Public: Exports a hash with the serialized data for this proposal.
      def serialize
        {
          id: proposal.id,
          category: {
            id: proposal.category.try(:id),
            name: proposal.category.try(:name) || empty_translatable
          },
          scope: {
            id: proposal.scope.try(:id),
            name: proposal.scope.try(:name) || empty_translatable
          },
          participatory_space: {
            id: proposal.participatory_space.id,
            url: Decidim::ResourceLocatorPresenter.new(proposal.participatory_space).url
          },
          collaborative_draft_origin: proposal.collaborative_draft_origin,
          component: { id: component.id },
          title: present(proposal).title,
          body: present(proposal).body,
          state: proposal.state.to_s,
          reference: proposal.reference,
          answer: ensure_translatable(proposal.answer),
          supports: proposal.proposal_votes_count,
          endorsements: proposal.endorsements.count,
          comments: proposal.comments.count,
          amendments: proposal.amendments.count,
          attachments_url: attachments_url,
          attachments: proposal.attachments.count,
          followers: proposal.followers.count,
          published_at: proposal.published_at,
          url: url,
          meeting_urls: meetings,
          related_proposals: related_proposals
        }.merge(options_merge(admin_extra_fields))
      end

      private

      attr_reader :proposal

      def admin_extra_fields
        {
          authors: extract_author_data do
            {
              names: proposal.authors.collect(&:name).join(","),
              nicknames: proposal.authors.collect(&:nickname).join(","),
              emails: proposal.authors.collect(&:email).join(","),
              authors_registration_metadata: authors_registration_metadata
            }
          end
        }
      end

      # Private: Returns the Hash block given if the proposal creator is a User
      #
      # Returns: Hash block or Hash with keys / empty values
      def extract_author_data
        if proposal.creator.decidim_author_type == "Decidim::Organization" && proposal.creator_identity.is_a?(Decidim::Organization) || !block_given?
          {
            names: "",
            nicknames: "",
            emails: "",
            authors_registration_metadata: ""
          }
        else
          yield
        end
      end

      def component
        proposal.component
      end

      def meetings
        proposal.linked_resources(:meetings, "proposals_from_meeting").map do |meeting|
          Decidim::ResourceLocatorPresenter.new(meeting).url
        end
      end

      def related_proposals
        proposal.linked_resources(:proposals, "copied_from_component").map do |proposal|
          Decidim::ResourceLocatorPresenter.new(proposal).url
        end
      end

      def url
        Decidim::ResourceLocatorPresenter.new(proposal).url
      end

      def attachments_url
        proposal.attachments.map { |attachment| proposal.organization.host + attachment.url }
      end

      def authors_registration_metadata
        proposal.authors.collect(&:registration_metadata)
      end
    end
  end
end
