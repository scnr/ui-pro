class HttpRequest < ActiveRecord::Base
    belongs_to :requestable, polymorphic: true

    serialize :headers,    Hash
    serialize :parameters, Hash

    def http_method=( m )
        super m.to_s.upcase
    end

    def to_s
        raw
    end

    def self.create_from_arachni( request )
        create(
            url:         request.url,
            http_method: request.method,
            body:        request.effective_body,
            parameters:  request.parameters,
            headers:     request.headers,
            raw:         request.to_s
        )
    end

end
