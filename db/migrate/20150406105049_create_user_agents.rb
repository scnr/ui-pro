class CreateUserAgents < ActiveRecord::Migration
    def change
        create_table :user_agents do |t|
            t.boolean :default
            t.string  :name
            t.text    :http_user_agent
            t.integer :browser_cluster_screen_width
            t.integer :browser_cluster_screen_height

            t.timestamps
        end
    end
end
