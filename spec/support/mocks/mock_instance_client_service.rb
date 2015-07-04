class MockInstanceClientService
    def pause( &block )
        block.call
    end

    def resume( &block )
        block.call
    end

    def scan( options, &block )
        block.call
    end

    def native_progress( &block )
        block.call
    end

    def native_abort_and_report( &block )
        block.call
    end
end
