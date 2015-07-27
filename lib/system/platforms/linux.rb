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

    # @private
    def _exec( cmd )
        %x(#{cmd})
    end

    class <<self
        def current?
            ruby_platform =~ /linux/i
        end
    end

end

end
end
