class CreateHttpResponses < ActiveRecord::Migration[5.1]
    def change
        create_table :http_responses do |t|
            t.text :url
            t.integer :code
            t.string :ip_address
            t.binary :headers
            t.binary :body
            t.float :time
            t.string :return_code
            t.text :return_message
            t.binary :raw_headers
            t.belongs_to :responsable, polymorphic: true, index: true

            t.timestamps
        end

        add_index :http_responses, :url
    end
end
