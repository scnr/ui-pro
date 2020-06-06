FactoryGirl.define do
    factory :sitemap_entry do
        url { "http://test.com/#{rand(999999999)}" }
        code 200
        scan { FactoryGirl.create(:scan) }
        site { FactoryGirl.create(:site) }
        revision { |i| FactoryGirl.create( :revision, scan: i.scan ) }
    end
end
