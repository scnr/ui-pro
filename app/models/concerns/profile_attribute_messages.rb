require 'active_support/concern'

module ProfileAttributeMessages
    extend ActiveSupport::Concern

    DESCRIPTIONS_FILE = "#{Rails.root}/config/profile/attributes.yml"

    module ClassMethods
        def string_for( attribute, type = nil )
            @descriptions ||= YAML.load( IO.read( DESCRIPTIONS_FILE ) )

            case description = @descriptions[attribute.to_s]
                when String
                    return if type != :description
                    description
                when Hash
                    description[type.to_s]
            end
        end

        def description_for( attribute )
            string_for( attribute, :description )
        end

        def notice_for( attribute )
            string_for( attribute, :notice )
        end

        def warning_for( attribute )
            string_for( attribute, :warning )
        end
    end

    def description_for( attribute )
        self.class.description_for( attribute )
    end

    def notice_for( attribute )
        self.class.notice_for( attribute )
    end

    def warning_for( attribute )
        self.class.warning_for( attribute )
    end
end
