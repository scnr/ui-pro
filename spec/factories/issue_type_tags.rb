FactoryGirl.define do
    factory :issue_type_tag do
        name { "xss #{rand(9999999)}"}
        description "XSS issue."
    end
end
