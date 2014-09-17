class CreateSchedules < ActiveRecord::Migration
    def change
        create_table :schedules do |t|
            t.integer :month_frequency
            t.integer :day_frequency
            t.datetime :start_at
            t.float :stop_after_hours
            t.boolean :stop_suspend
            t.belongs_to :scan

            t.timestamps
        end
    end
end
