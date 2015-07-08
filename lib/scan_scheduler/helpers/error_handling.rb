class ScanScheduler
module Helpers
module ErrorHandling

    def handle_if_rpc_error( revision, response )
        return if !response.rpc_exception?

        handle_rpc_error( revision, response )

        true
    end

    def handle_rpc_error( revision, error )
        log_exception_for( revision, error )

        revision.scan.failed!

        finish revision
    end

end
end
end
