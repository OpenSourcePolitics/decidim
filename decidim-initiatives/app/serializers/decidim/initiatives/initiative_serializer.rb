# frozen_string_literal: true

module Decidim
  module Initiatives
    class InitiativeSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with an initiative.
      def initialize(initiative)
        @initiative = initiative
      end

      # Public: Exports a hash with the serialized data for this initiative.
      def serialize
        {
          id: initiative.id,
          reference: initiative.reference,
          title: initiative.title,
          description: initiative.description,
          created_at: initiative.created_at,
          published_at: initiative.published_at,
          hashtag: initiative.hashtag,
          type: {
            id: initiative.type.try(:id),
            name: initiative.type.try(:title) || empty_translatable
          },
          scope: {
            id: initiative.scope.try(:id),
            name: initiative.scope.try(:name) || empty_translatable
          },
          signatures: initiative.supports_count,
          signature_type: initiative.signature_type,
          signature_start_date: initiative.signature_start_date,
          signature_end_date: initiative.signature_end_date,
          state: initiative.state,
          offline_votes: initiative.offline_votes,
          answer: initiative.answer,
          attachments: {
            attachment_collections: serialize_attachment_collections,
            files: serialize_attachments
          },
          components: serialize_components,
          authors: {
            id: initiative.author_users.map(&:id),
            name: initiative.author_users.map(&:name)
          },
          area: {
            name: initiative.area&.name
          },
          firms: {
            scopes: uniq_vote_scopes
          }
        }
      end

      private

      attr_reader :initiative

      def serialize_attachment_collections
        return unless initiative.attachment_collections.any?

        initiative.attachment_collections.map do |collection|
          {
            id: collection.try(:id),
            name: collection.try(:name),
            weight: collection.try(:weight),
            description: collection.try(:description)
          }
        end
      end

      def serialize_attachments
        return unless initiative.attachments.any?

        initiative.attachments.map do |attachment|
          {
            id: attachment.try(:id),
            title: attachment.try(:title),
            weight: attachment.try(:weight),
            description: attachment.try(:description),
            attachment_collection: {
              name: attachment.attachment_collection.try(:name),
              weight: attachment.attachment_collection.try(:weight),
              description: attachment.attachment_collection.try(:description)
            },
            remote_file_url: Decidim::AttachmentPresenter.new(attachment).attachment_file_url
          }
        end
      end

      def serialize_components
        serializer = Decidim::Exporters::ParticipatorySpaceComponentsSerializer.new(@initiative)
        serializer.serialize
      end

      def uniq_vote_scopes
        return 0 if initiative.votes.blank?

        initiative_votes_scopes = []
        initiative.votes.map(&:decrypted_metadata).each do |metadata|
          next if metadata.blank?
          next unless metadata.is_a? Hash

          initiative_votes_scopes << metadata[:user_scope_id]
        end

        initiative_votes_scopes.uniq.size
      end
    end
  end
end
