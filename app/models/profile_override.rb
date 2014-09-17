class ProfileOverride < ActiveRecord::Base
    include ProfileRpcHelpers
    include ProfileAttributes
    include GlobalProfileAttributes

    belongs_to :profile_overridable, polymorphic: true

    RPC_OPTS = Profile::RPC_OPTS + GlobalProfile::RPC_OPTS + [:scope_page_limit]
end
