# frozen_string_literal: true

require "spec_helper"
require "support/tasks"
require "rake"

describe "user:destroy_accounts", type: :task do
  let(:user_choice) { "" }

  before do
    allow(STDIN).to receive(:gets).and_return(user_choice)
  end

  it "asks user to confirm her choice" do
    expect { task.execute }.to output(/destroy_accounts is a critical command, please confirm your choice/).to_stdout
  end

  context "when user does not confirms her choice" do
    let(:user_choice) { "n" }

    before do
      allow(STDIN).to receive(:gets).and_return(user_choice)
    end

    it "exits with a code status 2" do
      expect { task.execute }.to output(/Choice not confirmed, rake task aborted : Exit status 2/).to_stdout
    end
  end

  context "when user confirms her choice" do
    let(:user_choice) { "y" }

    before do
      allow(STDIN).to receive(:gets).and_return(user_choice)
    end

    context "when there is no users to destroy" do
      it "exits with a code status 1" do
        expect { task.execute }.to output(/No users found, rake task aborted : Exit status 1/).to_stdout
      end
    end

    context "when users are defined" do
      let!(:users_without_invitation_token) do
        create_list(:user, 5,
                    current_sign_in_at: nil,
                    current_sign_in_ip: nil,
                    last_sign_in_at: nil,
                    invitation_accepted_at: nil,
                    deleted_at: nil,
                    invitation_sent_at: Date.new(2019, 1, 1),
                    admin: false)
      end
      let!(:deleted_user) { create(:user, :confirmed, :deleted) }
      let!(:confirmed_user) { create(:user, :confirmed) }
      let!(:deleted_unconfirmed_user) { create(:user, :deleted) }

      before do
        # rubocop:disable FactoryBot/CreateList
        # Here rubocop FactoryBot is disabled because invitation_token needs to be unique
        8.times do
          create(:user, current_sign_in_at: nil,
                        current_sign_in_ip: nil,
                        last_sign_in_at: nil,
                        invitation_accepted_at: nil,
                        deleted_at: nil,
                        invitation_token: Faker::Crypto.sha1,
                        invitation_sent_at: Date.new(2019, 1, 1),
                        admin: false)
        end
        # rubocop:enable FactoryBot/CreateList
      end

      it "does not raise SystemExit error" do
        expect { task.execute }.not_to raise_error SystemExit
      end

      it "finds 8 accounts to destroy" do
        expect { task.execute }.to output(/Total destroyed: 8/).to_stdout
      end

      it "destroys accounts" do
        task.execute

        users = Decidim::User.where.not(delete_reason: nil)
        expect(users.count).to eq(8)
      end
    end
  end
end
