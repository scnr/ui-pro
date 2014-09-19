# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
    factory :issue_type do
        name "XSS"
        check_shortname "xss"
        description "XSS vuln."
        remedy_guidance "MyText"
        severity { FactoryGirl.create :issue_type_severity }
        tags { [FactoryGirl.create(:issue_type_tag) ]}
        references { [FactoryGirl.create(:issue_type_reference) ]}
        cwe 1
    end
end
