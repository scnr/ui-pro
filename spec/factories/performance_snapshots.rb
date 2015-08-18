FactoryGirl.define do
    factory :performance_snapshot do
        http_request_count 120209
        http_response_count 120209
        http_time_out_count 162
        http_average_responses_per_second 41.08373646212503
        http_average_response_time 0.3961567054297138
        http_max_concurrency 10
        http_original_max_concurrency 20
        runtime 3356.181309559
        page_count 84
        current_page 'http://stuff.com/path/here/'
    end
end
