# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe StatutoryRepresentativeMailer, type: :mailer do
    let(:user) { create(:user, name: "Sarah Connor") }

    describe "inform" do
      let(:mail) { described_class.inform(user) }

      it "delivers email" do
        expect(mail.subject).to eq("A new underage user has been created")
        expect(email_body(mail)).to include("A new underage user has registered on #{user.organization.name} with name: #{user.name} and nickname: #{user.nickname}")
      end
    end
  end
end
