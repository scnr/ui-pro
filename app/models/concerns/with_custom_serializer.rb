require 'active_support/concern'

module WithCustomSerializer
    extend ActiveSupport::Concern

    module ClassMethods
        def custom_serialize( attribute, klass )
            serialize attribute, CustomSerializer
            after_initialize do
                self[attribute] ||= klass.new
            end
        end
    end

end
