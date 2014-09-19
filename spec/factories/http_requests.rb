# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
    factory :http_request do
        url "http://127.0.0.2:4567/stuff?pname=pvalue"
        http_method :get
        parameters({
            'pname' => 'pvalue'
        })
        headers({
            "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "User-Agent" => "Arachni/v2.0dev"
        })
        raw <<EOHTML
GET /stuff?pname=pvalue&1=2 HTTP/1.1
Host: 127.0.0.2:4567
Accept-Encoding: gzip, deflate
User-Agent: Arachni/v2.0dev
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8

EOHTML
    end
end
