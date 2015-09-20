class System
    include Singleton

    # Is there a better way to get this?
    PAGESIZE = 4096

    # @return   [Array<Platforms::Base>]
    attr_reader :platforms

    def initialize
        @platforms = []
    end

    # @return   [Integer]
    #   Amount of free RAM in bytes.
    def memory_free
        platform.memory_free
    end

    # @param    [Integer]   pgid
    #   Process group ID.
    #
    # @return   [Integer]
    #   Amount of RAM in bytes used by the given GPID.
    def memory_for_process_group( pgid )
        platform.memory_for_process_group( pgid )
    end

    # @param    [Integer]   pgid
    #   Process group ID.
    def kill_group( pgid )
        platform.kill_group( pgid )
    end

    # @return   [Integer]
    #   Amount of CPU cores.
    def cpu_count
        @cpu_count ||= platform.cpu_count
    end

    # @return   [Platforms::Base]
    def platform
        return @platform if @platform

        platforms.each do |klass|
            next if !klass.current?

            return @platform = klass.new
        end

        raise "Unsupported platform: #{RUBY_PLATFORM}"
    end

    # @private
    def register_platform( platform )
        platforms << platform
    end

    # @private
    def reset
        @cpu_count = nil
        @platform  = nil
    end

    class <<self
        def method_missing( sym, *args, &block )
            if instance.respond_to?( sym )
                instance.send( sym, *args, &block )
            else
                super( sym, *args, &block )
            end
        end

        def respond_to?( *args )
            super || instance.respond_to?( *args )
        end
    end

end

require_relative 'system/platforms'
