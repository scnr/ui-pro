class ScanScheduler
module Helpers
module ErrorHandling

    def handle_if_rpc_error( revision, response )
        return if !response.rpc_exception?

        handle_rpc_error( revision, response )
    end

    def handle_rpc_error( revision, error )
        log_exception_for( revision, error )
        kill_instance_for( revision )
    end

end
end
end
