# frozen_string_literal: true

module Decidim
  module Meetings
    class RegistrationSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper

      # Serializes a registration
      def serialize
        {
          id: resource.id,
          code: resource.code,
          user: {
            name: resource.user.try(:name),
            nickname: resource.user.try(:nickname),
            email: resource.user.try(:email),
            birth_date: registration_metadata(resource.user, :birth_date),
            gender: registration_metadata(resource.user, :gender),
            work_area: registration_metadata(resource.user, :work_area),
            residential_area: registration_metadata(resource.user, :residential_area),
            statutory_representative_email: registration_metadata(resource.user, :statutory_representative_email),
            user_group: resource.user_group&.name || ""
          },
          registration_form_answers: serialize_answers
        }
      end

      private

      # Private: Returns an array of registration_metadata of all authors for a specific sym_target key given
      #
      # Aim: Collect specific key from array of hash
      def registration_metadata(user, sym_target)
        registration_metadata = user.try(:registration_metadata)
        return "" if registration_metadata.nil?

        if sym_target == :work_area
          scope_area_name(user.try(:registration_metadata)[sym_target.to_s])
        elsif sym_target == :residential_area
          scope_area_name(user.try(:registration_metadata)[sym_target.to_s])
        else
          user.try(:registration_metadata)[sym_target.to_s] || ""
        end
      end

      def serialize_answers
        questions = resource.meeting.questionnaire.questions
        answers = resource.meeting.questionnaire.answers.where(user: resource.user)
        questions.each_with_index.inject({}) do |serialized, (question, idx)|
          answer = answers.find_by(question: question)
          serialized.update("#{idx + 1}. #{translated_attribute(question.body)}" => normalize_body(answer))
        end
      end

      def normalize_body(answer)
        return "" unless answer

        answer.body || answer.choices.pluck(:body)
      end
    end
  end
end
