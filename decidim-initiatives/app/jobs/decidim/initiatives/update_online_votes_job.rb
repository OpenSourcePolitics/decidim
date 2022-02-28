# frozen_string_literal: true

module Decidim
  module Initiatives
    class UpdateOnlineVotesJob < ApplicationJob
      queue_as :default

      # Actualize each initiative's online votes count jsonb field
      # Block can be passed to each initiative (reseting votes_counter_cache <Integer> for example)
      def perform(&block)
        Rails.logger.info("[UpdateOnlineVotesJob] :: JOB STARTED :: Updating initiatives online votes...")

        Decidim::Initiative.find_each do |initiative|
          yield if block_given?

          initiative.update_online_votes_counters
        end

        Rails.logger.info("[UpdateOnlineVotesJob] :: JOB TERMINATED :: All initiatives have been updated")
      end

      private
    end
  end
end
