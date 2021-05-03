# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Debates
    describe DebateSerializer do
      subject do
        described_class.new(debate)
      end

      let!(:debate) { create(:debate, :with_author) }
      let(:participatory_process) { debate.component.participatory_space }

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include("ID" => debate.id)
        end

        it "serializes the comments count" do
          expect(serialized).to include("Comments" => debate.comments.count)
        end

        it "serializes the component" do
          expect(serialized).to include("Component")
          expect(serialized["Component"]).to include("ID" => debate.component.id)
        end

        it "serializes the participatory space" do
          expect(serialized["Participatory space"]).to include("ID" => participatory_process.id)
          expect(serialized["Participatory space"]["URL"]).to include("http", participatory_process.slug)
        end

        it "serializes the creation date" do
          expect(serialized).to include("Creation date" => debate.created_at)
        end

        it "serializes the start time" do
          expect(serialized).to include("Start time" => debate.start_time)
        end

        it "serializes the end time" do
          expect(serialized).to include("End time" => debate.end_time)
        end

        it "serializes the author url" do
          expect(serialized).to include("Author url")
        end

        it "doesn't serializes the user data" do
          expect(serialized).not_to include("User")
        end

        context "when export is made by administrator on backoffice" do
          subject do
            described_class.new(debate, true)
          end

          it "serializes user data" do
            expect(serialized).to include("User")
            expect(serialized["User"]).to include("Name" => debate.author.try(:name))
            expect(serialized["User"]).to include("Nickname" => debate.author.try(:nickname))
            expect(serialized["User"]).to include("Email" => debate.author.try(:email))
            expect(serialized["User"]).to include("Birth date" => debate.author.registration_metadata[:birth_date.to_s].to_s)
            expect(serialized["User"]).to include("Gender" => debate.author.registration_metadata[:gender.to_s])
            expect(serialized["User"]).to include("Work area" => debate.author.registration_metadata[:work_area.to_s])
            expect(serialized["User"]).to include("Residential area" => debate.author.registration_metadata[:residential_area.to_s])
            expect(serialized["User"]).to include("Statutory representative email" => debate.author.registration_metadata[:statutory_representative_email.to_s])
          end

          context "when creator is the organization" do
            let!(:debate) { create(:debate) }

            it "serializes user data" do
              expect(serialized).to include("User")
              expect(serialized["User"]).to include("Name")
              expect(serialized["User"]).to include("Nickname")
              expect(serialized["User"]).to include("Email")
              expect(serialized["User"]).to include("Birth date")
              expect(serialized["User"]).to include("Gender")
              expect(serialized["User"]).to include("Work area")
              expect(serialized["User"]).to include("Residential area")
              expect(serialized["User"]).to include("Statutory representative email")
            end

            it "leaves empty each values" do
              expect(serialized["User"]["Name"]).to be_empty
              expect(serialized["User"]["Nickname"]).to be_empty
              expect(serialized["User"]["Email"]).to be_empty
              expect(serialized["User"]["Birth date"]).to be_empty
              expect(serialized["User"]["Gender"]).to be_empty
              expect(serialized["User"]["Work area"]).to be_empty
              expect(serialized["User"]["Residential area"]).to be_empty
              expect(serialized["User"]["Statutory representative email"]).to be_empty
            end
          end
        end
      end
    end
  end
end