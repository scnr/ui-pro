class HttpRequest < ActiveRecord::Base
    belongs_to :with_http_request, polymorphic: true

    serialize :headers,    Hash
    serialize :parameters, Hash

    def http_method=( m )
        super m.to_s.upcase
    end

end
