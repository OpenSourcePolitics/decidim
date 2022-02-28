# frozen_string_literal: true

module Decidim
  module Initiatives
    class UpdateVoteCounterCacheJob < ApplicationJob
      queue_as :default

      # Actualize each initiative's votes counter cache
      # Block can be passed to each initiative (updating online_votes <jsonb> for example)
      def perform(&block)
        Rails.logger.info("[UpdateVoteCounterCacheJob] :: JOB STARTED :: Updating initiatives votes counter cache...")

        Decidim::Initiative.find_each do |initiative|
          yield if block_given?

          Decidim::Initiative.reset_counters(initiative.id, :votes)
        end

        Rails.logger.info("[UpdateVoteCounterCacheJob] :: JOB TERMINATED :: All initiatives have been updated")
      end

      private
    end
  end
end
