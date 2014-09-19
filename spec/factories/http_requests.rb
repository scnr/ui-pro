# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
    factory :http_request do
        url "http://test.com/stuff?pname=pvalue"
        http_method :get
        parameters({
            'pname' => 'pvalue'
        })
        body ""
        headers({
            'User-Agent' => 'Arachni v1'
        })
        raw "MyText"
    end
end
