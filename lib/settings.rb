class Settings

    def initialize
        fail 'Cannot initialize.'
    end

    class <<self
        def method_missing( sym, *args, &block )
            if record.respond_to?( sym )
                record.send( sym, *args, &block )
            else
                super( sym, *args, &block )
            end
        end

        def respond_to?( *args )
            super || record.respond_to?( *args )
        end

        def record
            @record ||= reset
        end

        def reset
            @record = Setting.first
        end
    end
    reset

end
