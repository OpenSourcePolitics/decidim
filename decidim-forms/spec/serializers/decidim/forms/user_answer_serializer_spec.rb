# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe UserAnswersSerializer do
      subject do
        described_class.new(questionnaire.answers)
      end

      let!(:questionable) { create(:dummy_resource) }
      let!(:questionnaire) { create(:questionnaire, questionnaire_for: questionable) }
      let!(:user) { create(:user, organization: questionable.organization) }
      let!(:questions) { create_list :questionnaire_question, 3, questionnaire: questionnaire }
      let!(:answers) do
        questions.map do |question|
          create :answer, questionnaire: questionnaire, question: question, user: user
        end
      end

      let!(:multichoice_question) { create :questionnaire_question, questionnaire: questionnaire, question_type: "multiple_option" }
      let!(:multichoice_answer_options) { create_list :answer_option, 2, question: multichoice_question }
      let!(:multichoice_answer) do
        create :answer, questionnaire: questionnaire, question: multichoice_question, user: user, body: nil
      end
      let!(:multichoice_answer_choices) do
        multichoice_answer_options.map do |answer_option|
          create :answer_choice, answer: multichoice_answer, answer_option: answer_option, body: answer_option.body[I18n.locale.to_s]
        end
      end

      let!(:singlechoice_question) { create :questionnaire_question, questionnaire: questionnaire, question_type: "single_option" }
      let!(:singlechoice_answer_options) { create_list :answer_option, 2, question: multichoice_question }
      let!(:singlechoice_answer) do
        create :answer, questionnaire: questionnaire, question: singlechoice_question, user: user, body: nil
      end
      let!(:singlechoice_answer_choice) do
        answer_option = singlechoice_answer_options.first
        create :answer_choice, answer: singlechoice_answer, answer_option: answer_option, body: answer_option.body[I18n.locale.to_s], custom_body: "Free text"
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "includes the answer for each question" do
          questions.each_with_index do |question, idx|
            expect(serialized).to include(
              "#{idx + 1}. #{translated(question.body, locale: I18n.locale)}" => answers[idx].body
            )
          end

          expect(serialized).to include(
            "4. #{translated(multichoice_question.body, locale: I18n.locale)}" => multichoice_answer_choices.map(&:body)
          )

          expect(serialized).to include(
            "5. #{translated(singlechoice_question.body, locale: I18n.locale)}" => ["Free text"]
          )
        end

        context "and includes the attributes" do
          let!(:an_answer) { create(:answer, questionnaire: questionnaire, question: questions.sample, user: user) }

          it "the id of the answer" do
            key = I18n.t(:id, scope: "decidim.forms.user_answers_serializer")
            expect(serialized[key]).to eq an_answer.id
          end

          it "the creation of the answer" do
            key = I18n.t(:created_at, scope: "decidim.forms.user_answers_serializer")
            expect(serialized[key]).to eq an_answer.created_at.to_s(:db)
          end
        end

        it "doesn't includes user data" do
          expect(serialized).not_to include(:user_name)
          expect(serialized).not_to include(:user_nickname)
          expect(serialized).not_to include(:user_email)
          expect(serialized).not_to include(:user_birth_date)
          expect(serialized).not_to include(:user_gender)
          expect(serialized).not_to include(:user_work_area)
          expect(serialized).not_to include(:user_residential_area)
          expect(serialized).not_to include(:user_statutory_representative_email)
        end

        context "when export is made by administrator" do
          subject do
            described_class.new(questionnaire.answers, true)
          end

          let(:serialized) { subject.serialize }

          it "serializes user data" do
            expect(serialized[t("decidim.forms.user_answers_serializer.user_name")]).to eq(user.name)
            expect(serialized[t("decidim.forms.user_answers_serializer.user_nickname")]).to eq(user.nickname)
            expect(serialized[t("decidim.forms.user_answers_serializer.user_email")]).to eq(user.email)
            expect(serialized[t("decidim.forms.user_answers_serializer.user_birth_date")]).to eq(user.registration_metadata[:birth_date.to_s])
            expect(serialized[t("decidim.forms.user_answers_serializer.user_gender")]).to eq(user.registration_metadata[:gender.to_s])
            expect(serialized[t("decidim.forms.user_answers_serializer.user_work_area")]).to eq(user.registration_metadata[:work_area.to_s])
            expect(serialized[t("decidim.forms.user_answers_serializer.user_residential_area")]).to eq(user.registration_metadata[:residential_area.to_s])
            expect(serialized[t("decidim.forms.user_answers_serializer.user_statutory_representative_email")]).to eq(user.registration_metadata[:statutory_representative_email.to_s])
          end

          context "when there is no user" do
            let(:user) { nil }

            it "includes empty user data" do
              expect(serialized[t("decidim.forms.user_answers_serializer.user_name")]).to be_empty
              expect(serialized[t("decidim.forms.user_answers_serializer.user_nickname")]).to be_empty
              expect(serialized[t("decidim.forms.user_answers_serializer.user_email")]).to be_empty
              expect(serialized[t("decidim.forms.user_answers_serializer.user_birth_date")]).to be_empty
              expect(serialized[t("decidim.forms.user_answers_serializer.user_gender")]).to be_empty
              expect(serialized[t("decidim.forms.user_answers_serializer.user_work_area")]).to be_empty
              expect(serialized[t("decidim.forms.user_answers_serializer.user_residential_area")]).to be_empty
              expect(serialized[t("decidim.forms.user_answers_serializer.user_statutory_representative_email")]).to be_empty
            end
          end

          context "when user has no registration metadata" do
            before do
              user.update!(registration_metadata: nil)
            end

            it "doesn't includes user registration metadata" do
              expect(serialized[t("decidim.forms.user_answers_serializer.user_birth_date")]).to be_empty
              expect(serialized[t("decidim.forms.user_answers_serializer.user_gender")]).to be_empty
              expect(serialized[t("decidim.forms.user_answers_serializer.user_work_area")]).to be_empty
              expect(serialized[t("decidim.forms.user_answers_serializer.user_residential_area")]).to be_empty
              expect(serialized[t("decidim.forms.user_answers_serializer.user_statutory_representative_email")]).to be_empty
            end
          end

          it "includes user columns" do
            expect(serialized).to include(t("decidim.forms.user_answers_serializer.user_name"))
            expect(serialized).to include(t("decidim.forms.user_answers_serializer.user_nickname"))
            expect(serialized).to include(t("decidim.forms.user_answers_serializer.user_email"))
            expect(serialized).to include(t("decidim.forms.user_answers_serializer.user_birth_date"))
            expect(serialized).to include(t("decidim.forms.user_answers_serializer.user_gender"))
            expect(serialized).to include(t("decidim.forms.user_answers_serializer.user_work_area"))
            expect(serialized).to include(t("decidim.forms.user_answers_serializer.user_residential_area"))
            expect(serialized).to include(t("decidim.forms.user_answers_serializer.user_statutory_representative_email"))
          end
        end
      end
    end
  end
end
