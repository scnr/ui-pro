class System
module Platforms
class Linux < Base

    # @return   [Integer]
    #   Amount of free RAM in bytes.
    def memory_free
        lines = _exec('free').split("\n")

        # Old `free`.
        if lines.size == 4
            line = lines[2]

        # New `free`.
        else
            line = lines[1]
        end

        line .split("\s").last.to_i * 1024
    end

    # @return   [Integer]
    #   Amount of CPU cores.
    def cpu_count
        IO.read( '/proc/cpuinfo' ).split( "\n\n" ).size
    end

    # @param    [Integer]   pgid
    #   Process group ID.
    #
    # @return   [Integer]
    #   Amount of RAM in bytes used by the given PGID.
    def memory_for_process_group( pgid )
        rss = 0

        _exec( "ps -eo rss -g #{pgid}" ).split("\n")[1..-1].each do |rss_string|
            rss += rss_string.to_i
        end

        rss * System::PAGESIZE
    end

    # @param    [Integer]   pgid
    #   Process group ID.
    def kill_group( pgid )
        Timeout.timeout 2 do
            while sleep 0.1 do
                begin
                    Process.kill( '-TERM', pgid )
                rescue Errno::ESRCH
                    return
                end
            end
        end
    rescue Timeout::Error
    end

    class <<self
        def current?
            ruby_platform =~ /linux/i
        end
    end

end

end
end
