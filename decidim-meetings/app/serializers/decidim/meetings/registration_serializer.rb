# frozen_string_literal: true

module Decidim
  module Meetings
    class RegistrationSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper

      # Serializes a registration
      def serialize
        {
          translated_column_name(:id, "decidim.meetings.admin.exports.column_name.registrations") => resource.id,
          translated_column_name(:code, "decidim.meetings.admin.exports.column_name.registrations") => resource.code,
          translated_column_name(:user, "decidim.meetings.admin.exports.column_name.registrations.user") => {
            translated_column_name(:name, "decidim.meetings.admin.exports.column_name.registrations.user") => resource.user.try(:name),
            translated_column_name(:nickname, "decidim.meetings.admin.exports.column_name.registrations.user") => resource.user.try(:nickname),
            translated_column_name(:email, "decidim.meetings.admin.exports.column_name.registrations.user") => resource.user.try(:email),
            translated_column_name(:registration_metadata, "decidim.meetings.admin.exports.column_name.registrations.user") => resource.user.try(:registration_metadata) || "",
            translated_column_name(:user_group, "decidim.meetings.admin.exports.column_name.registrations.user") => resource.user_group&.name || ""
          },
          translated_column_name(:registration_form_answers, "decidim.meetings.admin.exports.column_name.registrations.user") => serialize_answers
        }
      end

      private

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
