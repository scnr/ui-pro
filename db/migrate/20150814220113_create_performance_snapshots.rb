class CreatePerformanceSnapshots < ActiveRecord::Migration[5.1]
    def change
        create_table :performance_snapshots do |t|
            t.integer :http_request_count
            t.integer :http_response_count
            t.integer :http_time_out_count
            t.float :http_average_responses_per_second
            t.float :http_average_response_time
            t.integer :http_max_concurrency
            t.integer :http_original_max_concurrency
            t.float :runtime
            t.integer :page_count
            t.text :current_page

            t.integer :revision_current_id, index: true
            t.belongs_to :revision

            t.timestamps null: false
        end
    end
end
