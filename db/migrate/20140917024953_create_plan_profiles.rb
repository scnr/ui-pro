class CreatePlanProfiles < ActiveRecord::Migration
    def change
        create_table :plan_profiles do |t|
            t.integer :scope_page_limit
            t.belongs_to :plan

            t.timestamps
        end
    end
end
