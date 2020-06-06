class InputVector < ActiveRecord::Base
    belongs_to :sitemap_entry, counter_cache: true, optional: true

    serialize :inputs,         CustomSerializer # Hash
    serialize :default_inputs, CustomSerializer # Hash

    def kind
        super.to_sym
    end

    def http_method=( m )
        super m.to_s.upcase
    end

    def engine_class
        SCNR::Engine::Element.const_get(
            super.gsub( 'SCNR::Engine::Element::', '' ).split( '::' ).first.to_sym
        )
    end

    def to_s
        kind.to_s.gsub( '_', ' ' ).sub( 'dom', 'DOM' ).sub( 'ui', 'UI' )
    end

    def self.create_from_engine( vector, options = {}  )
        h = {}
        [:action, :http_method, :seed, :inputs, :affected_input_name, :source,
         :default_inputs].each do |attr|
            h[attr] = vector.send(attr) if vector.respond_to?( attr )
        end

        h[:kind]         = vector.class.type
        h[:engine_class] = vector.class.to_s

        create h.merge( options )
    end

end
