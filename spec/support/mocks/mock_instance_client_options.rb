class MockInstanceClientOptions
    def set( options, &block )
        block.call
    end
end
