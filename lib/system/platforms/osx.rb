class System
module Platforms
class Osx < Base

    # @return   [Integer]
    #   Amount of free RAM in bytes.
    def memory_free
        m = memory
        m.pagesize * m.free
    end

    # @return   [Integer]
    #   Amount of CPU cores.
    def cpu_count
        Vmstat.cpu.size
    end

    # @private
    def memory
        Vmstat.memory
    end

    # @param    [Integer]   pgid
    #   Process group ID.
    #
    # @return   [Integer]
    #   Amount of RAM in bytes used by the given GPID.
    def memory_for_process_group( pgid )
        rss = 0

        _exec( "ps -g #{pgid}" ).split("\n")[1..-1].each do |rss_string|
            rss += rss_string.to_i
        end

        rss * System::PAGESIZE
    end

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
            ruby_platform =~ /darwin|mac os/i
        end
    end

end
end
end
