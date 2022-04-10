class CreatePerformanceSnapshots < ActiveRecord::Migration[5.1]
    def change
        create_table :performance_snapshots do |t|
            t.integer :http_request_count, default: 0
            t.integer :http_response_count, default: 0
            t.integer :http_time_out_count, default: 0
            t.float :http_average_responses_per_second, default: 0.0
            t.float :http_average_response_time, default: 0.0
            t.integer :http_max_concurrency, default: 0
            t.integer :http_original_max_concurrency, default: 0
            t.float :runtime, default: 0.0
            t.integer :page_count, default: 0
            t.text :current_page

            t.integer :revision_current_id, index: true
            t.belongs_to :revision

            t.timestamps null: false
        end
    end
end
