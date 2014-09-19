class CreateIssuePageDomStackFrames < ActiveRecord::Migration
    def change
        create_table :issue_page_dom_stack_frames do |t|
            t.integer :line
            t.text :url
            t.belongs_to :with_dom_stack_frame, polymorphic: true, index: {
                name: :issue_page_dom_stack_frames_poly_index
            }

            t.timestamps
        end
    end
end
