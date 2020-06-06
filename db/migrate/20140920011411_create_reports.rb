class CreateReports < ActiveRecord::Migration[5.1]
    def change
        create_table :reports do |t|
            t.belongs_to :revision, index: true
            t.text :location

            t.timestamps
        end
    end
end
