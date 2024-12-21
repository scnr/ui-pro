class HttpRequest < ActiveRecord::Base
    include WithCustomSerializer

    belongs_to :requestable, polymorphic: true, optional: true

    custom_serialize :headers,        Hash
    custom_serialize :parameters,     Hash
    custom_serialize :execution_flow, Hash
    custom_serialize :data_flow,      Hash

    def http_method=( m )
        super m.to_s.upcase
    end

    def to_s
        raw
    end

    def self.create_from_engine( request )
        create(
            url:         request.url,
            http_method: request.method,
            body:        request.effective_body,
            parameters:  request.parameters,
            headers:     request.headers,
            raw:         request.to_s,

            execution_flow: request.execution_flow&.to_rpc_data || {},
            data_flow:      request.data_flow&.to_rpc_data || {}
        )
    end

end
