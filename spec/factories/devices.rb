FactoryGirl.define do
    factory :device do
        name { "MyString #{rand(99999)}" }
        device_user_agent 'SCNR::Engine/v1.0'
        device_width 1200
        device_height 1600
        device_pixel_ratio 1.0
        device_touch   false
    end
end
