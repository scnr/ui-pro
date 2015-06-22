class CreateScans < ActiveRecord::Migration
  def change
    create_table :scans do |t|
      t.string :name
      t.text :description
      t.text :path
      t.integer :revisions_count, :integer, default: 0
      t.integer :issues_count, :integer, default: 0
      t.integer :sitemap_entries_count, :integer, default: 0

      t.belongs_to :site, index: true
      t.belongs_to :user_agent
      t.belongs_to :site_role

      t.timestamps
    end
  end
end
