class Setting < ActiveRecord::Base
    include ProfileRpcHelpers
    include ProfileAttributes

    def self.get
        first
    end
end
