# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe PseudomizeMailer, type: :mailer do
      let!(:organization) { create(:organization) }

      describe "#notify_admin" do
        let(:admin) { create(:user, :admin, name: "Sarah Connor", organization: organization) }
        let(:mail) { described_class.notify_admin(admin) }

        it "sets a subject" do
          expect(mail.subject).to include("The pseudomysation of the component is completed")
        end
      end

      describe "#notify_user" do
        let(:user) { create(:user, name: "Sarah Connor", organization: organization) }
        let(:mail) { described_class.notify_user(user) }

        it "sets a subject" do
          expect(mail.subject).to include("Your contributions have been anonymized")
        end
      end
    end
  end
end
