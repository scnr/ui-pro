# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
    factory :profile do
        default false
        name { "MyString #{rand(99999)}" }
        description "This is my profile!"
        scope_redundant_path_patterns(
            'redundant'       => 2,
            'other-redundant' => 3
        )
        audit_links true
        audit_forms true
        audit_cookies true
        audit_headers false
        checks ['xss', 'xss_tag']
        http_cookies(
            'my-name'      => 'my value',
            'another-name' => 'another value'
        )
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
        http_request_headers(
            'X-Custom-Header' => 'stuff',
            'X-Special-Auth'  => 'secret'
        )
        scope_restrict_paths [
            'only-include-me',
            'only-include-me-too'
        ]
        scope_extend_paths [
            'include-me', 'include-me-too'
        ]
        session_check_url 'http://stuff/'
        session_check_pattern 'logout.php'
        no_fingerprinting false
        platforms ["linux", 'php']
        http_authentication_username "johny"
        http_authentication_password "secret"
        input_values(
            'user'     => 'john',
            'password' => 'secret',
            'address'  => 'Somewhere 17'
        )
        audit_link_templates [
             'input1/(?<input1>\w+)/input2/(?<input2>\w+)'
        ]
        audit_include_vector_patterns [
            'search', 'username'
        ]
        audit_exclude_vector_patterns [
            'token', 'csrf'
        ]
        scope_url_rewrites(
            'articles\/[\w-]+\/(\d+)' => 'articles.php?id=\1'
        )
        browser_cluster_screen_width 1000
        browser_cluster_screen_height 1000
        scope_directory_depth_limit 10
        http_request_redirect_limit 5
        http_request_concurrency 20
        http_response_max_size 200_000
        scope_include_subdomains false
        plugins(
            'uncommon_headers' => nil,
            'headers_collector'  => {
                'include' => 'text/html'
            }
        )
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
