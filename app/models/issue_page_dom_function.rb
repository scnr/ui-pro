class IssuePageDomFunction < ActiveRecord::Base
    belongs_to :with_dom_function, polymorphic: true

    serialize :arguments, Array

    def self.create_from_arachni( function )
        create(
            name:      function.name,
            source:    function.source,
            arguments: function.arguments
        )
    end
end
