# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CreateRegistration do
    describe "call" do
      let(:organization) { create(:organization) }

      let(:name) { "Username" }
      let(:nickname) { "nickname" }
      let(:email) { "user@example.org" }
      let(:password) { "Y1fERVzL2F" }
      let(:password_confirmation) { password }
      let(:tos_agreement) { "1" }
      let(:newsletter) { "1" }

      let(:residential_area) { create(:scope, organization: organization).id.to_s }
      let(:work_area) { create(:scope, organization: organization).id.to_s }
      let(:gender) { "other" }
      let(:birth_date) do
        {
          month: "January",
          year: "1992"
        }
      end
      let(:underage) { "1" }
      let(:statutory_representative_email) { "statutory-representative@example.org" }

      let(:registration_metadata) do
        {
          residential_area: residential_area,
          work_area: work_area,
          gender: gender,
          birth_date: birth_date,
          statutory_representative_email: statutory_representative_email
        }
      end

      let(:form_params) do
        {
          "user" => {
            "name" => name,
            "nickname" => nickname,
            "email" => email,
            "password" => password,
            "password_confirmation" => password_confirmation,
            "tos_agreement" => tos_agreement,
            "newsletter_at" => newsletter,
            "residential_area" => residential_area,
            "work_area" => work_area,
            "gender" => gender,
            "birth_date" => birth_date,
            "underage" => underage,
            "statutory_representative_email" => statutory_representative_email
          }
        }
      end
      let(:form) do
        RegistrationForm.from_params(
          form_params
        ).with_context(
          current_organization: organization
        )
      end
      let(:command) { described_class.new(form) }

      describe "when the form is not valid" do
        before do
          expect(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "doesn't create a user" do
          expect do
            command.call
          end.not_to change(User, :count)
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "creates a new user" do
          expect(User).to receive(:create!).with(
            name: form.name,
            nickname: form.nickname,
            email: form.email,
            password: form.password,
            password_confirmation: form.password_confirmation,
            tos_agreement: form.tos_agreement,
            newsletter_notifications_at: form.newsletter_at,
            email_on_notification: true,
            organization: organization,
            accepted_tos_version: organization.tos_version,
            registration_metadata: registration_metadata
          ).and_call_original

          expect { command.call }.to change(User, :count).by(1)
        end

        describe "when user keep uncheck newsletter" do
          let(:newsletter) { "0" }

          it "creates a user with no newsletter notifications" do
            expect do
              command.call
              expect(User.last.newsletter_notifications_at).to eq(nil)
            end.to change(User, :count).by(1)
          end
        end
      end
    end
  end
end
