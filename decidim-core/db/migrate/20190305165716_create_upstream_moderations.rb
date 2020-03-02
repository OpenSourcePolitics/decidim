# frozen_string_literal: true

class CreateUpstreamModerations < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_upstream_moderations do |t|
      t.references :decidim_participatory_process, null: false, index: { name: "decidim_upstream_moderations_participatory_process" }
      t.references :decidim_upstream_reportable, null: false, polymorphic: true, index: { unique: true, name: "decidim_upstream_moderations_reportable" }
      t.integer :report_count, null: false, default: 0, index: { name: "decidim_upstream_moderations_report_count" }
      t.datetime :hidden_at, index: { name: "decidim_upstream_moderations_hidden_at" }

      t.timestamps
    end
    remove_index :decidim_upstream_moderations,
                 name: "decidim_upstream_moderations_participatory_process"

    add_column :decidim_upstream_moderations, :decidim_participatory_space_type, :string

    reversible do |direction|
      direction.up do
        execute <<~SQL.squish
          UPDATE decidim_upstream_moderations
          SET decidim_participatory_space_type = 'Decidim::ParticipatoryProcess'
        SQL
      end
    end

    rename_column :decidim_upstream_moderations,
                  :decidim_participatory_process_id,
                  :decidim_participatory_space_id

    add_index :decidim_upstream_moderations,
              [:decidim_participatory_space_id, :decidim_participatory_space_type],
              name: "decidim_upstream_moderations_participatory_space"

    change_column_null :decidim_upstream_moderations, :decidim_participatory_space_type, false
  end
end
