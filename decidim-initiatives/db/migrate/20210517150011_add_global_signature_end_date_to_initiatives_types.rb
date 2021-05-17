# frozen_string_literal: true

class AddGlobalSignatureEndDateToInitiativesTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_initiatives_types, :global_signature_end_date, :date, null: true, default: nil
  end
end
