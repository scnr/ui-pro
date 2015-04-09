FactoryGirl.define do
    factory :site_role do
        name "MyString"
        description "MyText"
        session_check_url 'http://stuff/'
        session_check_pattern 'logout.php'
        scope_exclude_path_patterns [
            'exclude-that', 'exclude-that-too'
        ]
        login_type 'form'
        login_form_url { site.url }
        login_form_parameters ({
            'username' => 'joe',
            'password' => 'secret'
        })
        login_script_code { 'puts 1' }
        site { FactoryGirl.create( :site ) }
    end
end
