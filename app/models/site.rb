class Site < ActiveRecord::Base
    has_and_belongs_to_many :users

    PROTOCOL_TYPES = %w(http https)

    validates_presence_of :protocol
    validates             :protocol, inclusion: {
        in:      PROTOCOL_TYPES,
        message: "Acceptable types are: #{PROTOCOL_TYPES.join( ', ' )}"
    }

    validates_presence_of :host
    validates_format_of   :host,
                          with: /\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}\z/

    validates_presence_of     :port
    validates_numericality_of :port

    def url
        u = "#{protocol}://#{host}"

        if (protocol == 'http' && port == 80) ||
            (protocol == 'https' && port == 443)
            return u
        end

        "#{u}:#{port}"
    end
    alias :to_s :url

end
