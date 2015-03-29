require 'active_support/concern'

module ProfileExport
    extend ActiveSupport::Concern

    def export( serializer = YAML )
        profile_hash = to_rpc_options
        profile_hash[:name] = name
        profile_hash[:description] = description

        profile_hash = profile_hash.stringify_keys
        if serializer == JSON
            JSON.pretty_generate profile_hash
        else
            serializer.dump profile_hash
        end
    end

end
