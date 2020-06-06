class CreateSitesUsers < ActiveRecord::Migration[5.1]
    def change
        create_table :sites_users, id: false do |t|
            t.references :site
            t.references :user
        end

        add_index :sites_users, [:site_id, :user_id]
    end
end
