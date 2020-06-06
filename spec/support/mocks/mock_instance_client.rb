class MockInstanceClient
    def url
        @url ||= "localhost:#{rand(99999999)}"
    end

    def options
        @options ||= MockInstanceClientOptions.new
    end

    def method_missing( sym, *args, &block )
        (@service ||= MockInstanceClientService.new).send( sym, *args, &block )
    end

end
