class SiteVerification < ActiveRecord::Base

    STATES_BY_TYPE = {
        done: Set.new([:failed, :verified, :error])
    }

    VALID_STATES = (STATES_BY_TYPE.values.map(&:to_a).flatten | [:pending, :started])

    belongs_to :site
    before_create :set_attributes

    validate :state, in: VALID_STATES

    VALID_STATES.each do |s|
        define_method "#{s}?" do
            self.state == s
        end

        define_method "#{s}!" do
            self.state = s
            save
        end
    end

    STATES_BY_TYPE.each do |type, values|
        define_method "#{type}?" do
            values.include? self.state
        end
    end

    def state
        super.to_sym
    end

    def url
        "#{site.url}/#{filename}"
    end

    private

    def set_attributes
        self.filename = "#{SecureRandom.hex( 4 )}.txt"
        self.code     = SecureRandom.hex

        true
    end
end
