class CreateSitemapEntries < ActiveRecord::Migration
    def change
        create_table :sitemap_entries do |t|
            t.text :url
            t.integer :code
            t.belongs_to :revision, index: true

            t.timestamps
        end
    end
end
