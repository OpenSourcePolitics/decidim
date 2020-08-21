# frozen_string_literal: true

class ChangeDefaultInitiativeVotesCounterCaches < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_initiatives, :online_votes, from: {}, to: { "total": 0 }
    change_column_default :decidim_initiatives, :offline_votes, from: {}, to: { "total": 0 }
  end
end
