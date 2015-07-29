class CreateIssuePageDomFunctions < ActiveRecord::Migration
    def change
        create_table :issue_page_dom_functions do |t|
            t.binary :source
            t.binary :arguments
            t.text :name
            t.belongs_to :with_dom_function, polymorphic: true, index: {
                name: :issue_page_dom_functions_poly_index
            }

            t.timestamps
        end

        add_index :issue_page_dom_functions, :name
    end
end
