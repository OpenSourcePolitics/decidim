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
          translated_column_name(:id, "decidim.proposals.admin.exports.column_name.proposals") => proposal.id,
          translated_column_name(:category, "decidim.proposals.admin.exports.column_name.proposals.category") => {
            translated_column_name(:id, "decidim.proposals.admin.exports.column_name.proposals.category") => proposal.category.try(:id),
            translated_column_name(:name, "decidim.proposals.admin.exports.column_name.proposals.category") => proposal.category.try(:name) || empty_translatable
          },
          translated_column_name(:scope, "decidim.proposals.admin.exports.column_name.proposals.scope") => {
            translated_column_name(:id, "decidim.proposals.admin.exports.column_name.proposals.scope") => proposal.scope.try(:id),
            translated_column_name(:name, "decidim.proposals.admin.exports.column_name.proposals.scope") => proposal.scope.try(:name) || empty_translatable
          },
          translated_column_name(:participatory_space, "decidim.proposals.admin.exports.column_name.proposals.participatory_space") => {
            translated_column_name(:id, "decidim.proposals.admin.exports.column_name.proposals.participatory_space") => proposal.participatory_space.id,
            translated_column_name(:url, "decidim.proposals.admin.exports.column_name.proposals.participatory_space") => Decidim::ResourceLocatorPresenter.new(proposal.participatory_space).url
          },
          translated_column_name(:collaborative_draft_origin, "decidim.proposals.admin.exports.column_name.proposals") => proposal.collaborative_draft_origin,
          translated_column_name(:component, "decidim.proposals.admin.exports.column_name.proposals.component") => { translated_column_name(:id, "decidim.proposals.admin.exports.column_name.proposals.component") => component.id },
          translated_column_name(:title, "decidim.proposals.admin.exports.column_name.proposals") => present(proposal).title,
          translated_column_name(:body, "decidim.proposals.admin.exports.column_name.proposals") => present(proposal).body,
          translated_column_name(:state, "decidim.proposals.admin.exports.column_name.proposals") =>  proposal.state.to_s,
          translated_column_name(:reference, "decidim.proposals.admin.exports.column_name.proposals") =>  proposal.reference,
          translated_column_name(:answer, "decidim.proposals.admin.exports.column_name.proposals") =>  ensure_translatable(proposal.answer),
          translated_column_name(:supports, "decidim.proposals.admin.exports.column_name.proposals") =>  proposal.proposal_votes_count,
          translated_column_name(:endorsements, "decidim.proposals.admin.exports.column_name.proposals") => proposal.endorsements.count,
          translated_column_name(:comments, "decidim.proposals.admin.exports.column_name.proposals") => proposal.comments.count,
          translated_column_name(:amendments, "decidim.proposals.admin.exports.column_name.proposals") => proposal.amendments.count,
          translated_column_name(:attachments_url, "decidim.proposals.admin.exports.column_name.proposals") => attachments_url,
          translated_column_name(:attachments, "decidim.proposals.admin.exports.column_name.proposals") => proposal.attachments.count,
          translated_column_name(:followers, "decidim.proposals.admin.exports.column_name.proposals") => proposal.followers.count,
          translated_column_name(:published_at, "decidim.proposals.admin.exports.column_name.proposals") => proposal.published_at,
          translated_column_name(:url, "decidim.proposals.admin.exports.column_name.proposals") => url,
          translated_column_name(:meeting_urls, "decidim.proposals.admin.exports.column_name.proposals") => meetings,
          translated_column_name(:related_proposals, "decidim.proposals.admin.exports.column_name.proposals") => related_proposals
        }.merge(options_merge(admin_extra_fields))
      end

      private

      attr_reader :proposal

      def admin_extra_fields
        {
          translated_column_name(:authors, "decidim.proposals.admin.exports.column_name.proposals.authors") => extract_author_data do
            {
              translated_column_name(:names, "decidim.proposals.admin.exports.column_name.proposals.authors") => proposal.authors.collect(&:name).join(","),
              translated_column_name(:nicknames, "decidim.proposals.admin.exports.column_name.proposals.authors") => proposal.authors.collect(&:nickname).join(","),
              translated_column_name(:emails, "decidim.proposals.admin.exports.column_name.proposals.authors") => proposal.authors.collect(&:email).join(","),
              translated_column_name(:authors_registration_metadata, "decidim.proposals.admin.exports.column_name.proposals.authors") => authors_registration_metadata
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
            translated_column_name(:names, "decidim.proposals.admin.exports.column_name.proposals.authors") => "",
            translated_column_name(:nicknames, "decidim.proposals.admin.exports.column_name.proposals.authors") => "",
            translated_column_name(:emails, "decidim.proposals.admin.exports.column_name.proposals.authors") => "",
            translated_column_name(:authors_registration_metadata, "decidim.proposals.admin.exports.column_name.proposals.authors") => ""
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
