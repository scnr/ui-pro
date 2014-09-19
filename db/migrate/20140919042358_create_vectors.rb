class CreateVectors < ActiveRecord::Migration
    def change
        create_table :vectors do |t|
            t.text :original_inputs
            t.text :inputs
            t.text :seed
            t.string :arachni_class
            t.string :type
            t.text :action
            t.text :html
            t.string :http_method
            t.text :affected_input_name
            t.belongs_to :with_vector, polymorphic: true, index: true

            t.timestamps
        end
    end
end
