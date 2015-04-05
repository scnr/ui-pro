# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
    factory :profile do
        default false
        name { "MyString #{rand(99999)}" }
        description "This is my profile!"
        audit_links true
        audit_forms true
        audit_cookies true
        audit_headers false
        checks ['xss', 'xss_tag']
        http_user_agent "Arachni/v0.0"
        scope_exclude_path_patterns [
            'exclude-this', 'eclude-this-too'
        ]
        scope_exclude_content_patterns [
            'Not found', 'Not found either'
        ]
        scope_include_path_patterns [
            'username', 'id'
        ]
        scope_restrict_paths [
            'only-include-me',
            'only-include-me-too'
        ]
        scope_extend_paths [
            'include-me', 'include-me-too'
        ]
        session_check_url 'http://stuff/'
        session_check_pattern 'logout.php'
        http_authentication_username "johny"
        http_authentication_password "secret"
        audit_include_vector_patterns [
            'search', 'username'
        ]
        audit_exclude_vector_patterns [
            'token', 'csrf'
        ]
        browser_cluster_screen_width 1000
        browser_cluster_screen_height 1000
        scope_directory_depth_limit 10
        http_request_redirect_limit 5
        http_response_max_size 200_000
        plugins(
            'uncommon_headers' => nil,
            'headers_collector'  => {
                'include' => 'text/html'
            }
        )
        scope_exclude_binaries true
        http_request_timeout 10_000
        http_request_queue_size 50
        scope_dom_depth_limit 10
        browser_cluster_pool_size 6
        browser_cluster_job_timeout 10
        browser_cluster_worker_time_to_live 100
        browser_cluster_ignore_images true
    end
end
