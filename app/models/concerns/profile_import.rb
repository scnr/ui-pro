require 'active_support/concern'

module ProfileImport
    extend ActiveSupport::Concern

    module ClassMethods
        def import( file )
            serialized = file.read

            data = begin
                JSON.load serialized
            rescue
                YAML.safe_load serialized rescue nil
            end

            return if !data.is_a?( Hash )

            data['name']        ||= file.original_filename
            data['description'] ||= "Imported from '#{file.original_filename}'."

            import_from_data( data )
        end

        def import_from_data( data )
            new flatten( data )
        end
    end
end
