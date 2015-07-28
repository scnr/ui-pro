class System
module Platforms
class Linux < Base

    # @return   [Integer]
    #   Amount of free RAM in bytes.
    def memory_free
        _exec('free').split("\n")[2].split("\s").last.to_i * 1024
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

        Sys::ProcTable.ps do |p|
            next if p.pgrp != pgid
            rss += p.rss
        end

        rss * System::PAGESIZE
    end

    class <<self
        def current?
            ruby_platform =~ /linux/i
        end
    end

end

end
end
