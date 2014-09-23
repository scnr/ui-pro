FactoryGirl.define do
    factory :issue_type_tag do
        name { "xss #{rand(9999)}"}
        description "XSS issue."
    end
end
