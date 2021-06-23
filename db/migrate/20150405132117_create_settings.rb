class CreateSettings < ActiveRecord::Migration[5.1]
    def change
        create_table :settings do |t|
            t.integer  :http_request_timeout
            t.integer  :http_request_queue_size
            t.integer  :http_request_redirect_limit
            t.integer  :http_response_max_size
            t.string   :http_proxy_host
            t.integer  :http_proxy_port
            t.string   :http_proxy_username
            t.string   :http_proxy_password

            t.integer  :dom_pool_size
            t.integer  :dom_job_timeout
            t.integer  :dom_worker_time_to_live

            t.integer  :max_parallel_scans

            t.timestamps
        end
    end
end
