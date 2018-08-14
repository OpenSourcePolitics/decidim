# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe NavbarLinksController, type: :controller do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) { create :organization }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:navbar_link) { create(:navbar_link, organization: organization) }

      before do
        sign_in user, scope: :admin
        request.env["decidim.current_organization"] = organization
      end

      describe "GET index" do
        it "renders the index template" do
          get :index
          expect(response).to redirect_to("/admin/navbar_links")
        end
      end

      context "when creating a navbar link" do
        let!(:navbar_link) { create(:navbar_link, organization: organization) }

        it "injects the link to the form" do
          post :create, params: { navbar_link: navbar_link }
          expect(assigns(:form).link).to eq(navbar_link.link)
        end

        it "calls CreateNavbarLink" do
          post :create, params: { navbar_link: navbar_link }
          expect_any_instance_of(CreateNavbarLink).to receive(:call)
        end

        it "had a flash notice if successfull" do
          post :create, params: { navbar_link: navbar_link }
          expect(flash[:notice]).to be_present
        end

        it "had a flash alert if invalid" do
          post :create, params: { organization: nil }
          expect(flash[:alert]).to be_present
        end
      end

      describe "when updating a navbar link" do
        context "with an organization present" do
          let!(:navbar_link) { create(:navbar_link, organization: organization) }

          it "injects the link to the form" do
            put :update, params: { id: navbar_link.id }.with_indifferent_access
            expect(assigns(:form).link).to eq(navbar_link.link)
          end

          it "had a flash notice if successfull" do
            post :update, params: { navbar_link: navbar_link }
            expect(flash[:notice]).to be_present
          end

          context "without an organization" do
            let!(:navbar_link) { create(:navbar_link) }

            it "had a flash alert if invalid" do
              post :update, params: { navbar_link: navbar_link }
              expect(flash[:alert]).to be_present
            end
          end
        end
      end

      context "when no link is given" do
        it "injects it to the form" do
          put :update, params: { id: navbar_link.id }.with_indifferent_access
          expect(assigns(:form).link).to eq(navbar_link.link)
        end
      end

      context "when a link is given" do
        it "does not overwrite it" do
          put :update, params: { id: navbar_link.id, navbar_link: { link: "http://example.org" } }.with_indifferent_access
          expect(assigns(:form).link).to eq("http://example.org")
        end
      end

      context "when a link is destroyed" do
        let(:navbar_link) { create(:navbar_link, organization: organization) }

        it "had a flash notice if successfull" do
          navbar_link.destroy!
          expect(flash[:notice]).to be_present
        end
      end
    end
  end
end
