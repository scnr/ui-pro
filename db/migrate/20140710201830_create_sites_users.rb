class CreateSitesUsers < ActiveRecord::Migration
    def change
        create_table :sites_users, id: false do |t|
            t.references :site
            t.references :user
        end

        add_index :sites_users, [:site_id, :user_id]
        add_index :sites_users, :user_id
    end
end
