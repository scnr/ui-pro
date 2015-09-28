class MockInstanceClient
    def url
        @url ||= "localhost:#{rand(99999999)}"
    end

    def service
        @service ||= MockInstanceClientService.new
    end

    def options
        @options ||= MockInstanceClientOptions.new
    end
end
