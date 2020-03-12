# frozen_string_literal: true

module Decidim
  module Debates
    # This class serializes a debate so can be exported to CSV, JSON or other
    # formats.
    class DebateSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a debate.
      def initialize(debate, private_scope = false)
        @debate = debate
        @private_scope = private_scope
      end

      # Public: Exports a hash with the serialized data for this debate.
      def serialize
        {
          id: debate.id,
          title: present(debate).title,
          description: present(debate).description,
          comments: debate.comments.count,
          url: url,
          category: {
            id: debate.category.try(:id),
            name: debate.category.try(:name) || empty_translatable
          },
          component: { id: component.id },
          participatory_space: {
            id: debate.participatory_space.id,
            url: Decidim::ResourceLocatorPresenter.new(debate.participatory_space).url
          },
          created_at: debate.created_at,
          start_time: debate.start_time,
          end_time: debate.end_time,
          author_url: Decidim::UserPresenter.new(debate.author).try(:profile_url)
        }.merge(options_merge(admin_extra_fields))
      end

      private

      attr_reader :debate

      def admin_extra_fields
        {
          user: extract_author_data do
            {
              name: debate.author.try(:name),
              nickname: debate.author.try(:nickname),
              email: debate.author.try(:email),
              birth_date: key_from_registration_metadata(debate.author, :birth_date).to_s,
              gender: key_from_registration_metadata(debate.author, :gender),
              work_area: key_from_registration_metadata(debate.author, :work_area),
              residential_area: key_from_registration_metadata(debate.author, :residential_area),
              statutory_representative_email: key_from_registration_metadata(debate.author, :statutory_representative_email)
            }
          end
        }
      end

      # Private: Returns the Hash block given if the proposal creator is a User
      #
      # Returns: Hash block or Hash with keys / empty values
      def extract_author_data
        if debate.author.is_a?(Decidim::Organization) || debate.author.is_a?(Decidim::UserGroup) || !block_given?
          {
            name: "",
            nickname: "",
            email: "",
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
        debate.component
      end

      def url
        Decidim::ResourceLocatorPresenter.new(debate).url
      end
    end
  end
end
