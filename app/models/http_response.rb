class HttpResponse < ActiveRecord::Base
    belongs_to :responsable, polymorphic: true

    serialize :headers, Hash

    def to_s
        "#{raw_headers}#{body}".recode
    end

    def self.create_from_arachni( response )
        create(
            url:            response.url,
            code:           response.code,
            ip_address:     response.ip_address,
            body:           response.body,
            time:           response.time,
            headers:        response.headers,
            return_code:    response.return_code,
            return_message: response.return_message,
            raw_headers:    response.headers_string
        )
    end
end
