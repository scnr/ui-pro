# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
    factory :http_request do
        to_create { |instance| instance.save( validate: false ) }

        url "http://127.0.0.2:4567/stuff?pname=pvalue"
        http_method :post
        parameters({})
        body '1=2'
        headers({
            "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "User-Agent" => "SCNR::Engine/v1.0dev"
        })
        raw <<EOHTML
POST /stuff?pname=pvalue HTTP/1.1
Host: 127.0.0.2:4567
Accept-Encoding: gzip, deflate
User-Agent: SCNR::Engine/v2.0dev
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Content-Length: 3
Content-Type: application/x-www-form-urlencoded

1=2
EOHTML
    end
end
