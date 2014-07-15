class CreateScans < ActiveRecord::Migration
  def change
    create_table :scans do |t|
      t.belongs_to :site, index: true
      t.boolean :enabled, default: false
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
