class CreateRevisions < ActiveRecord::Migration
  def change
    create_table :revisions do |t|
      t.belongs_to :scan, index: true
      t.belongs_to :site, index: true
      t.integer :index
      t.text :snapshot_path
      t.string :status
      t.boolean :timed_out
      t.datetime :started_at
      t.datetime :stopped_at

      t.integer :issues_count, :integer, default: 0
      t.integer :sitemap_entries_count, :integer, default: 0

      t.timestamps
    end
  end
end
