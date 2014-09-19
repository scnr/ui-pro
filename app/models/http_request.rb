class HttpRequest < ActiveRecord::Base
    belongs_to :requestable, polymorphic: true

    serialize :headers,    Hash
    serialize :parameters, Hash

    def http_method=( m )
        super m.to_s.upcase
    end

end
