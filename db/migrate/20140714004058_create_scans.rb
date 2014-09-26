class CreateScans < ActiveRecord::Migration
  def change
    create_table :scans do |t|
      t.string :name
      t.text :description
      t.integer :revisions_count, :integer, default: 0

      t.belongs_to :site, index: true
      t.belongs_to :plan, index: true

      t.timestamps
    end
  end
end
