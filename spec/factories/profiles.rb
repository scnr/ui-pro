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
        scope_exclude_path_patterns [
            'exclude-this', 'exclude-this-too'
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
        audit_include_vector_patterns [
            'search', 'username'
        ]
        audit_exclude_vector_patterns [
            'token', 'csrf'
        ]
        scope_directory_depth_limit 10
        plugins(
            'uncommon_headers' => nil,
            'headers_collector'  => {
                'include' => 'text/html'
            }
        )
        scope_exclude_binaries true
        scope_dom_depth_limit 10
    end
end
