class ScanScheduler
module Helpers
module Logging

    def initialize
        super

        @log_prefixes = {}
    end

    def log_exception_for( revision, e )
        log_error_for revision, "[#{e.class}] #{e}"
        (e.backtrace || []).each { |l| log_error_for revision, l }
    end

    def log_error_for( revision, line )
        Rails.logger.error prepare_log_line_for( revision, line )
    end

    def log_info_for( revision, line )
        Rails.logger.info prepare_log_line_for( revision, line )
    end

    def log_debug_for( revision, line )
        Rails.logger.debug prepare_log_line_for( revision, line )
    end

    def prepare_log_line_for( revision, line )
        @log_prefixes[revision.id] ||=
            "[#{revision.index.ordinalize} #{revision.scan}]"

        prepare_log_line "[#{@log_prefixes[revision.id]}] #{line}"
    end

    def log_exception( e )
        log_error "[#{e.class}] #{e}"
        (e.backtrace || []).each { |l| log_error l }
    end

    def log_info( line )
        Rails.logger.info prepare_log_line( line )
    end

    def log_error( line )
        Rails.logger.error prepare_log_line( line )
    end

    def prepare_log_line( line )
        "[#{self.class}##{@ticks}] #{line}"
    end

end
end
end
