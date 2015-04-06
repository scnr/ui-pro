FactoryGirl.define do
    factory :setting do
        http_request_timeout 10_000
        http_request_queue_size 50
        http_request_redirect_limit 5
        http_response_max_size 200_000

        browser_cluster_pool_size 6
        browser_cluster_job_timeout 10
        browser_cluster_worker_time_to_live 100
    end
end
