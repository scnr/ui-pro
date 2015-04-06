# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
    factory :site_profile do
        scope_redundant_path_patterns(
            'redundant'       => 2,
            'other-redundant' => 3
        )
        http_cookies(
            'my-name'      => 'my value',
            'another-name' => 'another value'
        )
        http_request_headers(
            'X-Custom-Header' => 'stuff',
            'X-Special-Auth'  => 'secret'
        )
        no_fingerprinting false
        platforms ["linux", 'php']
        input_values(
            'user'     => 'john',
            'password' => 'secret',
            'address'  => 'Somewhere 17'
        )
        audit_link_templates [
             'input1/(?<input1>\w+)/input2/(?<input2>\w+)'
         ]
        scope_url_rewrites(
            'articles\/[\w-]+\/(\d+)' => 'articles.php?id=\1'
        )
        http_request_concurrency 20
        scope_include_subdomains false
        scope_auto_redundant_paths 100
        scope_https_only false
        http_authentication_username "johny"
        http_authentication_password "secret"
        browser_cluster_ignore_images true
    end
end
