# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe UpdateVoteCounterCacheJob do
      subject { described_class.perform_now }
      let!(:initiative) { create(:initiative) }
      let!(:initiatives_votes) { create_list :initiative_user_vote, 5, initiative: initiative }

      before do
        allow(Decidim::Initiative).to receive(:reset_counters).with(initiative.id, :votes)
        allow(Rails.logger).to receive(:info)
      end

      it "loops on each initiative" do
        subject

        expect(Decidim::Initiative).to have_received(:reset_counters)
      end

      it "add messages to Rails logger" do
        subject

        expect(Rails.logger).to have_received(:info).at_least(2)
      end
    end
  end
end
