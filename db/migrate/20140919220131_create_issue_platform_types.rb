class CreateIssuePlatformTypes < ActiveRecord::Migration
    def change
        create_table :issue_platform_types do |t|
            t.string :shortname
            t.string :name

            t.timestamps
        end
        add_index :issue_platform_types, :shortname, unique: true
        add_index :issue_platform_types, :name, unique: true
    end
end
