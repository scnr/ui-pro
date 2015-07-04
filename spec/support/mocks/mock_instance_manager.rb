class MockInstanceManager
    def initialize
        @instances = {}
    end

    def spawn( &block )
        i = MockInstanceClient.new
        @instances[i.url] = i

        block.call i
    end

    def kill( url )
        @instances.delete i.url
    end

    def killall
        @instances.clear
    end

    def connect( url )
        @instances[url]
    end
end
