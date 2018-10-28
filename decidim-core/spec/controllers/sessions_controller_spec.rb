# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Devise
    describe SessionsController, type: :controller do
      routes { Decidim::Core::Engine.routes }

      describe "after_sign_in_path_for" do
        subject { controller.after_sign_in_path_for(user) }

        before do
          request.env["decidim.current_organization"] = user.organization
        end

        context "when the given resource is a user" do
          context "and is an admin" do
            let(:user) { build(:user, :admin, sign_in_count: 1) }

            before do
              controller.store_location_for(user, account_path)
            end

            it { is_expected.to eq account_path }
          end

          context "and is not an admin" do
            context "when it is the first time to log in" do
              let(:user) { build(:user, :confirmed, sign_in_count: 1) }

              # the first test would fail if tested in a non linear order, this corrects this problem.
              # TODO : Find a more elegant solution
              initial_value = Decidim.config.skip_first_login_authorization

              context "when there are authorization handlers" do
                context "when there is no skip first login authorization option" do
                  before do
                    Decidim.config.skip_first_login_authorization = initial_value
                    user.organization.available_authorizations = ["dummy_authorization_handler"]
                    user.organization.save
                  end
                  it { is_expected.to eq("/authorizations/first_login") }
                end

                context "when there is a skip first login authorization option activated" do
                  before do
                    Decidim.config.skip_first_login_authorization = false
                    user.organization.available_authorizations = ["dummy_authorization_handler"]
                    user.organization.save
                  end
                  it { is_expected.to eq("/authorizations/first_login") }
                end

                context "when there is a skip first login authorization option activated" do
                  before do
                    Decidim.config.skip_first_login_authorization = true
                    user.organization.available_authorizations = ["dummy_authorization_handler"]
                    user.organization.save
                  end
                  it { is_expected.to eq("/") }
                end

                context "when there's a pending redirection" do
                  before do
                    controller.store_location_for(user, account_path)
                  end

                  it { is_expected.to eq account_path }
                end

                context "when the user hasn't confirmed their email" do
                  before do
                    user.confirmed_at = nil
                  end

                  it { is_expected.to eq("/") }
                end
              end

              context "otherwise", with_authorization_workflows: [] do
                it { is_expected.to eq("/") }
              end
            end

            context "and it's not the first time to log in" do
              let(:user) { build(:user, sign_in_count: 2) }

              it { is_expected.to eq("/") }
            end
          end
        end
      end
    end
  end
end
