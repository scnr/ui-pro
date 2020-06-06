class CustomSerializer
    def self.load(data)
        return if !data
        MessagePack.load data
    end

    def self.dump(data)
        MessagePack.dump data
    end
end
