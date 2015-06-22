class CreateRevisions < ActiveRecord::Migration
  def change
    create_table :revisions do |t|
      t.belongs_to :scan, index: true
      t.belongs_to :site, index: true
      t.string :state
      t.integer :index
      t.datetime :started_at
      t.datetime :stopped_at
      t.text :snapshot_location

      t.integer :issues_count, :integer, default: 0
      t.integer :sitemap_entries_count, :integer, default: 0

      t.timestamps
    end
  end
end
