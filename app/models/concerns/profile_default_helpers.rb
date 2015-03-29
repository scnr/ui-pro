require 'active_support/concern'

module ProfileDefaultHelpers
    extend ActiveSupport::Concern

    module ClassMethods
        def default
            where( default: true ).first
        end
    end

    def default!
        self.class.update_all default: false
        self.default = true
        self.save
    end

end
