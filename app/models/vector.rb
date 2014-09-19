class Vector < ActiveRecord::Base
    belongs_to :with_vector, polymorphic: true

    serialize :inputs,          Hash
    serialize :original_inputs, Hash

    def http_method=( m )
        super m.to_s.upcase
    end
end
