FactoryGirl.define do
    factory :issue_page_dom_function do
        source "function decodeURI() {
    [native code]
}"
        arguments ["#%7Cinput%7Cdefault%3Csome_dangerous_input_c19b39d05da8ac6c4a1643ad7b2ca89b/%3E"]
        name "decodeURI"
    end
end
