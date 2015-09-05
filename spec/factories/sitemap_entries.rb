FactoryGirl.define do
    factory :sitemap_entry do
        url { "http://test.com/#{rand(999999999)}" }
        code 200
    end
end
