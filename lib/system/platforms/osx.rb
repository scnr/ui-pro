class System
module Platforms
class OSX < Base

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

    class <<self
        def current?
            ruby_platform =~ /darwin|mac os/i
        end
    end

end
end
end
