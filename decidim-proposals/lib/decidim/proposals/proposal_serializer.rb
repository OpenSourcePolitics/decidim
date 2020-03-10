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
              birth_date: collect_registration_metadata(:birth_date).join(","),
              gender: collect_registration_metadata(:gender).join(","),
              work_area: collect_registration_metadata(:work_area).join(","),
              residential_area: collect_registration_metadata(:residential_area).join(","),
              statutory_representative_email: collect_registration_metadata(:statutory_representative_email).join(",")
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
            names: "",
            nicknames: "",
            emails: "",
            birth_date: "",
            gender: "",
            work_area: "",
            residential_area: "",
            statutory_representative_email: ""
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
