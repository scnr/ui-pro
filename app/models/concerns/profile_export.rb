require 'active_support/concern'

module ProfileExport
    extend ActiveSupport::Concern

    def export( serializer = YAML )
        profile_hash = to_rpc_options

        if has_option? :name
            profile_hash[:name] = name
        end

        if has_option? :description
            profile_hash[:description] = description
        end

        profile_hash = profile_hash.stringify_keys
        if serializer == JSON
            JSON.pretty_generate profile_hash
        else
            serializer.dump profile_hash
        end
    end

end
