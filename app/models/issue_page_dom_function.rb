class IssuePageDomFunction < ActiveRecord::Base
    belongs_to :with_dom_function, polymorphic: true

    serialize :arguments, Array

    def signature_arguments
        return [] if !signature
        signature.match( /\((.*)\)/ )[1].split( ',' ).map(&:strip)
    end

    def signature
        return if !source
        source.match( /function\s*(.*?)\s*\{/m )[1]
    end

    def self.create_from_arachni( function )
        create(
            name:      function.name,
            source:    function.source,
            arguments: function.arguments
        )
    end
end
