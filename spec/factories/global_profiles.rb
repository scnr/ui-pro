# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
    factory :global_profile do
        scope_directory_depth_limit 10
        http_request_redirect_limit 5
        http_request_concurrency 20
        http_response_max_size 200_000
        scope_include_subdomains false
        plugins(
            'myplugin'     => nil,
            'other_plugin' => {
                'my-option' => 'stuff'
            }
        )
        audit_with_both_http_methods false
        scope_exclude_binaries true
        scope_auto_redundant_paths 100
        scope_https_only false
        http_request_timeout 10_000
        http_request_queue_size 50
        scope_dom_depth_limit 10
        browser_cluster_pool_size 6
        browser_cluster_job_timeout 10
        browser_cluster_worker_time_to_live 100
        browser_cluster_ignore_images true
    end
end
