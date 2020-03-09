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
          t_column_name(:id) => proposal.id,
          t_column_name(:category, ".category") => {
            t_column_name(:id, ".category") => proposal.category.try(:id),
            t_column_name(:name, ".category") => proposal.category.try(:name) || empty_translatable
          },
          t_column_name(:scope, ".scope") => {
            t_column_name(:id, ".scope") => proposal.scope.try(:id),
            t_column_name(:name, ".scope") => proposal.scope.try(:name) || empty_translatable
          },
          t_column_name(:participatory_space, ".participatory_space") => {
            t_column_name(:id, ".participatory_space") => proposal.participatory_space.id,
            t_column_name(:url, ".participatory_space") => Decidim::ResourceLocatorPresenter.new(proposal.participatory_space).url
          },
          t_column_name(:collaborative_draft_origin) => proposal.collaborative_draft_origin,
          t_column_name(:component, ".component") => { t_column_name(:id, ".component") => component.id },
          t_column_name(:title) => present(proposal).title,
          t_column_name(:body) => present(proposal).body,
          t_column_name(:state) =>  proposal.state.to_s,
          t_column_name(:reference) =>  proposal.reference,
          t_column_name(:answer) =>  ensure_translatable(proposal.answer),
          t_column_name(:supports) =>  proposal.proposal_votes_count,
          t_column_name(:endorsements) => proposal.endorsements.count,
          t_column_name(:comments) => proposal.comments.count,
          t_column_name(:amendments) => proposal.amendments.count,
          t_column_name(:attachments_url) => attachments_url,
          t_column_name(:attachments) => proposal.attachments.count,
          t_column_name(:followers) => proposal.followers.count,
          t_column_name(:published_at) => proposal.published_at,
          t_column_name(:url) => url,
          t_column_name(:meeting_urls) => meetings,
          t_column_name(:related_proposals) => related_proposals
        }.merge(options_merge(admin_extra_fields))
      end

      private

      attr_reader :proposal

      def admin_extra_fields
        {
          t_column_name(:authors, ".authors") => extract_author_data do
            {
              t_column_name(:names, ".authors") => proposal.authors.collect(&:name).join(","),
              t_column_name(:nicknames, ".authors") => proposal.authors.collect(&:nickname).join(","),
              t_column_name(:emails, ".authors") => proposal.authors.collect(&:email).join(","),
              t_column_name(:birth_date, ".authors") => collect_registration_metadata(:birth_date).join(","),
              t_column_name(:gender, ".authors") => collect_registration_metadata(:gender).join(","),
              t_column_name(:work_area, ".authors") => collect_registration_metadata(:work_area).join(","),
              t_column_name(:residential_area, ".authors") => collect_registration_metadata(:residential_area).join(","),
              t_column_name(:statutory_representative_email, ".authors") => collect_registration_metadata(:statutory_representative_email).join(",")
            }
          end
        }
      end

      # Private: Returns an array of registration_metadata of all authors for a specific sym_target key given
      #
      # Aim: Collect specific key from array of hash
      def collect_registration_metadata(target_key)
        "" unless target_key.is_a?(Symbol)
        default_empty_value = multiple_authors? ? "-" : ""
        array = []
        registration_metadata = proposal.authors.collect(&:registration_metadata)

        if registration_metadata.first.nil?
          array << default_empty_value
        else
          registration_metadata.each { |hash| array << replace_empty_value(hash, default_empty_value)[target_key] }
        end

        array
      end

      # Private: Take a hash as parameter and returns this hash with sym keys and allows to replace empty values
      def replace_empty_value(hash, replaced_by = "-")
        return unless hash.is_a? Hash
        refactored_hash = {}
        hash.each_pair do |k, v|
          refactored_hash[k.to_sym] = if v.is_a? Hash
                                        replace_empty_value(v, replaced_by)
                                      else
                                        v.presence ? check_specific_key(k, v) : replaced_by
                                      end
        end
        refactored_hash
      end

      # Private: Returns the Hash block given if the proposal creator is a User
      #
      # Returns: Hash block or Hash with keys / empty values
      def extract_author_data
        if proposal.creator.decidim_author_type == "Decidim::Organization" && proposal.creator_identity.is_a?(Decidim::Organization) || !block_given?
          {
            t_column_name(:names, ".authors") => "",
            t_column_name(:nicknames, ".authors") => "",
            t_column_name(:emails, ".authors") => "",
            t_column_name(:birth_date, ".authors") => "",
            t_column_name(:gender, ".authors") => "",
            t_column_name(:work_area, ".authors") => "",
            t_column_name(:residential_area, ".authors") => "",
            t_column_name(:statutory_representative_email, ".authors") => ""
          }
        else
          yield
        end
      end

      def i18n_scope
        "decidim.proposals.admin.exports.column_name.proposals"
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

      def multiple_authors?
        proposal.authors.size > 1
      end

      # Private: Define a specific process for a given key
      def check_specific_key(key, value)
        return scope_area_name(value) if key == "work_area"
        return scope_area_name(value) if key == "residential_area"
        value
      end
    end
  end
end
