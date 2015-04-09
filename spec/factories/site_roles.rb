FactoryGirl.define do
    factory :site_role do
        name "MyString"
        description "MyText"
        session_check_url 'http://stuff/'
        session_check_pattern 'logout.php'
        plugins ({})
        scope_exclude_path_patterns [
            'exclude-that', 'exclude-that-too'
        ]
        site { FactoryGirl.create( :site ) }
    end

end
