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

        # @return   [Integer]
        #   Amount of CPU cores.
        #
        # @abstract
        def cpu_count
            raise 'Missing implementation'
        end
    end
end
end

Dir.glob( "#{File.dirname(__FILE__)}/**/*.rb" ).each do |platform|
    require platform
end
