FactoryGirl.define do
    factory :user_agent do
        name { "MyString #{rand(99999)}" }
        http_user_agent 'Arachni/v1.0'
        browser_cluster_screen_width 1200
        browser_cluster_screen_height 1600
    end
end
