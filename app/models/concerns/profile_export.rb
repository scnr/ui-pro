require 'active_support/concern'

module ProfileExport
    extend ActiveModel::Naming
    extend ActiveSupport::Concern

    def export( serializer = YAML )
        profile_hash = self.to_scanner_options

        if respond_to? :name
            profile_hash[:name] = name
        end

        if respond_to? :description
            profile_hash[:description] = description
        end

        profile_hash.stringify_keys!
        if serializer == JSON
            JSON.pretty_generate profile_hash
        else
            serializer.dump profile_hash
        end
    end

end
