class CreateSites < ActiveRecord::Migration
    def change
        create_table :sites do |t|
            t.integer :protocol
            t.string  :host
            t.integer :port, default: 80
            t.belongs_to :user, index: true

            t.timestamps
        end

        add_index :sites, [:protocol, :host, :port]
    end
end
