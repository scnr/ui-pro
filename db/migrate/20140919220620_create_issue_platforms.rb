class CreateIssuePlatforms < ActiveRecord::Migration
    def change
        create_table :issue_platforms do |t|
            t.string :shortname
            t.string :name
            t.belongs_to :issue_platform_type, index: true

            t.timestamps
        end
        add_index :issue_platforms, :shortname, unique: true
        add_index :issue_platforms, :name, unique: true
    end
end
