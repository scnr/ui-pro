class CreatePageDomStackFrames < ActiveRecord::Migration
    def change
        create_table :page_dom_stack_frames do |t|
            t.integer :line
            t.text :url
            t.belongs_to :traceable, polymorphic: true, index: true

            t.timestamps
        end
    end
end
