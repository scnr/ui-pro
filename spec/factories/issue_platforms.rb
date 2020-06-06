FactoryGirl.define do
    factory :issue_platform do
        shortname "mysql"
        name "MySQL"
        type { IssuePlatformType.first || FactoryGirl.create(:issue_platform_type) }
    end
end
