class CreateSites < ActiveRecord::Migration
    def change
        create_table :sites do |t|
            t.string  :protocol, default: 'http'
            t.string  :host
            t.integer :port, default: 80

            t.timestamps
        end
    end
end
