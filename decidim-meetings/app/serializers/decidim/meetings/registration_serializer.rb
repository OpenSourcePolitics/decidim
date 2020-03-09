# frozen_string_literal: true

module Decidim
  module Meetings
    class RegistrationSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper

      # Serializes a registration
      def serialize
        {
          t_column_name(:id) => resource.id,
          t_column_name(:code) => resource.code,
          t_column_name(:user, ".user") => {
            t_column_name(:name, ".user") => resource.user.try(:name),
            t_column_name(:nickname, ".user") => resource.user.try(:nickname),
            t_column_name(:email, ".user") => resource.user.try(:email),
            t_column_name(:birth_date, ".user") => key_from_registration_metadata(resource.user, :birth_date).to_s,
            t_column_name(:gender, ".user") => key_from_registration_metadata(resource.user, :gender),
            t_column_name(:work_area, ".user") => key_from_registration_metadata(resource.user, :work_area),
            t_column_name(:residential_area, ".user") => key_from_registration_metadata(resource.user, :residential_area),
            t_column_name(:statutory_representative_email, ".user") => key_from_registration_metadata(resource.user, :statutory_representative_email),
            t_column_name(:user_group, ".user") => resource.user_group&.name || ""
          },
          t_column_name(:registration_form_answers, ".user") => serialize_answers
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

      def i18n_scope
        "decidim.meetings.admin.exports.column_name.registrations"
      end

      def normalize_body(answer)
        return "" unless answer

        answer.body || answer.choices.pluck(:body)
      end
    end
  end
end
