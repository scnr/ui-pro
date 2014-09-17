require 'active_support/concern'

module ProfileOverride
    extend ActiveSupport::Concern

    included do
        serialize :profile_override, Hash

        validate :validate_profile_override
    end

    def validate_profile_override
        begin
            Arachni::Options.hash_to_rpc_data( profile_override || {} )
            true
        rescue NoMethodError => e
            errors.add :profile_override, e.to_s
            false
        end
    end
end
