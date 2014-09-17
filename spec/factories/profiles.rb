# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
    factory :profile do
        default false
        name "My profile"
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
    end
end
