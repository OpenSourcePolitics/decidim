# frozen_string_literal: true

class AddInitiativesVotesCountToDecidimInitiative < ActiveRecord::Migration[5.2]
  def up
    add_column :decidim_initiatives, :initiatives_votes_count, :integer

    Decidim::Initiative.find_each do |initiative|
      Decidim::Initiative.reset_counters(initiative.id, :votes)
    end
  end

  def down
    remove_column :decidim_initiatives, :initiatives_votes_count, :integer
  end
end
