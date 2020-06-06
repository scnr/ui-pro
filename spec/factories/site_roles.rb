FactoryGirl.define do
    factory :site_role do
        to_create { |instance| instance.save( validate: false ) }

        name { "MyString - #{rand 99999}" }
        description "MyText"
        session_check_url 'http://stuff/'
        session_check_pattern 'logout.php'
        scope_exclude_path_patterns [
            'site-role-exclude-that', 'site-role-exclude-that-too'
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
