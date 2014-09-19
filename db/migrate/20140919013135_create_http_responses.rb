class CreateHttpResponses < ActiveRecord::Migration
    def change
        create_table :http_responses do |t|
            t.text :url
            t.integer :code
            t.string :ip_address
            t.text :headers
            t.text :body
            t.float :time
            t.string :return_code
            t.string :return_message
            t.text :raw_headers
            t.belongs_to :responsable, polymorphic: true, index: true

            t.timestamps
        end
    end
end
