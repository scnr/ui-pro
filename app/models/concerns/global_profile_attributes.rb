require 'active_support/concern'

module GlobalProfileAttributes
    extend ActiveSupport::Concern

    included do
        serialize :plugins, Hash
    end

end
