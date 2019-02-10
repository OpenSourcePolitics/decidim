class ChangeDefaultStateProposals < ActiveRecord::Migration[5.2]
  def change

    Decidim::Proposals::Proposal.where(state: nil).find_each do |proposal|
      proposal.update state: "not_answered"
    end

    change_column_default :decidim_proposals_proposals, :state, from: nil, to: "not_answered"
    # change_column_null :decidim_proposals_proposals, :state, false
  end
end
