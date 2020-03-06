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
          expect(serialized).to include(id: debate.id)
        end

        it "serializes the comments count" do
          expect(serialized).to include(comments: debate.comments.count)
        end

        it "serializes the component" do
          expect(serialized).to include(:component)
          expect(serialized[:component]).to include(id: debate.component.id)
        end

        it "serializes the participatory space" do
          expect(serialized[:participatory_space]).to include(id: participatory_process.id)
          expect(serialized[:participatory_space][:url]).to include("http", participatory_process.slug)
        end

        it "serializes the creation date" do
          expect(serialized).to include(created_at: debate.created_at)
        end

        it "serializes the start time" do
          expect(serialized).to include(start_time: debate.start_time)
        end

        it "serializes the end time" do
          expect(serialized).to include(end_time: debate.end_time)
        end

        it "serializes the author url" do
          expect(serialized).to include(:author_url)
        end

        it "doesn't serializes the user data" do
          expect(serialized).not_to include(:user)
        end

        context "when export is made by administrator on backoffice" do
          subject do
            described_class.new(debate, true)
          end

          it "serializes user data" do
            expect(serialized).to include(:user)
            expect(serialized[:user]).to include(name: debate.author.try(:name))
            expect(serialized[:user]).to include(nickname: debate.author.try(:nickname))
            expect(serialized[:user]).to include(email: debate.author.try(:email))
            expect(serialized[:user]).to include(registration_metadata: debate.author.try(:registration_metadata))
          end

          context "when creator is the organization" do
            let!(:debate) { create(:debate) }

            it "serializes user data" do
              expect(serialized).to include(:user)
              expect(serialized[:user]).to include(:name)
              expect(serialized[:user]).to include(:nickname)
              expect(serialized[:user]).to include(:email)
              expect(serialized[:user]).to include(:registration_metadata)
            end

            it "leaves empty each values" do
              expect(serialized[:user][:name]).to be_empty
              expect(serialized[:user][:nickname]).to be_empty
              expect(serialized[:user][:email]).to be_empty
              expect(serialized[:user][:registration_metadata]).to be_empty
            end
          end
        end
      end
    end
  end
end
