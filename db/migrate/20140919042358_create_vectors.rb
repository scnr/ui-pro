class CreateVectors < ActiveRecord::Migration
    def change
        create_table :vectors do |t|
            t.text :default_inputs
            t.text :inputs
            t.text :seed
            t.string :arachni_class
            t.string :kind
            t.text :action
            t.text :source
            t.string :http_method
            t.text :affected_input_name
            t.belongs_to :with_vector, polymorphic: true, index: true

            t.timestamps
        end

        add_index :vectors, :kind
    end
end
