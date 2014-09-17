class CreateScans < ActiveRecord::Migration
  def change
    create_table :scans do |t|
      t.belongs_to :site, index: true
      t.belongs_to :plan, index: true
      t.string :name
      t.text :description
      t.text :profile_override

      t.timestamps
    end
  end
end
