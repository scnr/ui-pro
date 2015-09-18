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

        revision.error_messages = "#{revision.error_messages}[#{error.class}] #{error.to_s}\n"
        revision.error_messages << "#{(error.backtrace || []).join("\n")}\n"

        revision.failed!

        finish revision
    end

end
end
end
