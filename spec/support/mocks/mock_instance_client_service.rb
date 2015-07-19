class MockInstanceClientService
    def pause( &block )
        block.call
    end

    def resume( &block )
        block.call
    end

    def suspend( &block )
        block.call
    end

    def snapshot_path( &block )
        block.call '/my/path'
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
