# frozen_string_literal: true

require "spec_helper"
require "support/tasks"
require 'rake'

describe "user:destroy_accounts", type: :task do

  let(:users) { create_list(:user, 5) }
  let(:deleted_users) { create_list(:user, 3, :confirmed, :deleted) }
  let(:confirmed_users) { create_list(:user, 3, :confirmed) }
  let(:deleted_unconfirmed_users) { create_list(:user, 3, :deleted) }

  it "asks user to confirm her choice" do
    allow(STDIN).to receive(:gets).and_return('n')
    expect { task.execute }.to output(/destroy_accounts is a critical command, please confirm your choice/).to_stdout
    expect { task.execute }.to output(/Choice not confirmed, rake task aborted : Exit status 2/).to_stdout
  end
end
