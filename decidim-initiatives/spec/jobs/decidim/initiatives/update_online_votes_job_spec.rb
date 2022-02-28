# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe UpdateOnlineVotesJob do
      subject { described_class.perform_now }
      let!(:initiative) { create(:initiative) }
      let!(:initiatives_votes) { create_list :initiative_user_vote, 5, initiative: initiative }

      before do
        allow(Rails.logger).to receive(:info)
        initiative.update_column(:online_votes, { "total" => 0 })
      end

      it "loops on each initiative" do
        expect(initiative.online_votes).to eq({ "total" => 0 })
        subject

        expect(initiative.reload.online_votes).to eq({ "total" => 5, initiative.scope.id.to_s => 5})
      end

      it "add messages to Rails logger" do
        subject

        expect(Rails.logger).to have_received(:info).at_least(2)
      end
    end
  end
end
