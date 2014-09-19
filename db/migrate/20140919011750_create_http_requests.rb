class CreateHttpRequests < ActiveRecord::Migration
    def change
        create_table :http_requests do |t|
            t.text :url
            t.string :http_method
            t.text :parameters
            t.text :body
            t.text :headers
            t.text :raw
            t.belongs_to :with_http_request, polymorphic: true

            t.timestamps
        end
    end
end
