class Vector < ActiveRecord::Base
    belongs_to :with_vector, polymorphic: true

    serialize :inputs,         Hash
    serialize :default_inputs, Hash

    def kind
        super.to_sym
    end

    def http_method=( m )
        super m.to_s.upcase
    end

    def self.create_from_arachni( vector )
        h = {}
        [:action, :http_method, :seed, :inputs, :affected_input_name, :source,
         :default_inputs].each do |attr|
            h[attr] = vector.send(attr) if vector.respond_to?( attr )
        end

        h[:kind]          = vector.class.type
        h[:arachni_class] = vector.class.to_s

        create h
    end

end
