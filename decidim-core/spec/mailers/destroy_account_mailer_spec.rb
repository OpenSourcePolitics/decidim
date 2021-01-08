# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DestroyAccountMailer, type: :mailer do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, organization: organization) }

    describe "#notify" do
      let(:mail) { described_class.notify(user) }

      let(:subject) { "Un usuari ha esborrat el seu compte." }
      let(:default_subject) { "A user has deleted his account." }

      let(:body) { "Un usuari ha esborrat el seu compte. Us convidem a presentar les seves peticions." }
      let(:default_body) { "A user has deleted his account. We invite you to go and file his petitions." }

      include_examples "localised email"
    end
  end
end
