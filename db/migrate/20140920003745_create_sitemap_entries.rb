class CreateSitemapEntries < ActiveRecord::Migration
    def change
        create_table :sitemap_entries do |t|
            t.text :url
            t.integer :code
            t.integer :issues_count, :integer, default: 0
            t.integer :issue_pages_count, :integer, default: 0
            t.integer :vectors_count, :integer, default: 0

            # We could have done this via a through :revisions association in
            # the model but we need it here for deduplication and easier analytics.
            t.belongs_to :site, index: true
            t.belongs_to :scan, index: true
            t.belongs_to :revision, index: true

            t.timestamps
        end

        add_index :sitemap_entries, [:url, :site_id], unique: true
    end
end
