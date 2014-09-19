class CreatePageDomFunctions < ActiveRecord::Migration
    def change
        create_table :page_dom_functions do |t|
            t.text :source
            t.text :arguments
            t.text :name
            t.belongs_to :with_func, polymorphic: true, index: true

            t.timestamps
        end
    end
end
