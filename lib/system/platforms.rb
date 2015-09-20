class System
module Platforms
    class Base
        class <<self

            # @private
            def inherited( platform )
                System.register_platform platform
            end

            def ruby_platform
                RUBY_PLATFORM
            end

            # @return   [Bool]
            #   `true` if it's the current platform, `false` otherwise.
            #
            # @abstract
            def current?
                raise 'Missing implementation'
            end
        end

        # @return   [Integer]
        #   Amount of free RAM in bytes.
        #
        # @abstract
        def memory_free
            raise 'Missing implementation'
        end

        # @param    [Integer]   pgid
        #   Process group ID.
        #
        # @return   [Integer]
        #   Amount of RAM in bytes used by the given GPID.
        #
        # @abstract
        def memory_for_process_group( pgid )
            raise 'Missing implementation'
        end

        def kill_group( pgid )
            raise 'Missing implementation'
        end

        # @return   [Integer]
        #   Amount of CPU cores.
        #
        # @abstract
        def cpu_count
            raise 'Missing implementation'
        end

        # @private
        def _exec( cmd )
            %x(#{cmd})
        end
    end
end
end

Dir.glob( "#{File.dirname(__FILE__)}/**/*.rb" ).each do |platform|
    require platform
end
