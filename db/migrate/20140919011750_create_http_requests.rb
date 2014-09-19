class CreateHttpRequests < ActiveRecord::Migration
    def change
        create_table :http_requests do |t|
            t.text :url
            t.string :http_method
            t.text :parameters
            t.text :headers
            t.text :raw
            t.belongs_to :requestable, polymorphic: true, index: true

            t.timestamps
        end
    end
end
