class CreateRevisions < ActiveRecord::Migration
  def change
    create_table :revisions do |t|
      t.belongs_to :scan, index: true
      t.string :state
      t.integer :index
      t.datetime :started_at
      t.datetime :stopped_at
      t.string :snapshot_location

      t.timestamps
    end
  end
end
