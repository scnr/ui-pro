class CreateHttpRequests < ActiveRecord::Migration[5.1]
    def change
        create_table :http_requests do |t|
            t.text :url
            t.string :http_method
            t.binary :parameters
            t.binary :headers
            t.binary :body
            t.binary :raw
            t.belongs_to :requestable, polymorphic: true, index: true

            t.timestamps
        end

        add_index :http_requests, :url
    end
end
