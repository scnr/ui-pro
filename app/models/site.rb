class Site < ActiveRecord::Base
    PROTOCOL_TYPES = %w(http https)

    has_one :profile_override, as: :profile_overridable, dependent: :destroy,
            autosave: true
    accepts_nested_attributes_for :profile_override

    has_one :verification, dependent: :destroy, autosave: true,
            foreign_key: 'site_id', class: SiteVerification
    before_create :build_verification

    belongs_to :user
    has_and_belongs_to_many :users

    has_many :scans, dependent: :destroy
    has_many :revisions, through: :scans
    has_many :issues, through: :scans

    validates_presence_of :protocol
    validates             :protocol, inclusion: {
        in:      PROTOCOL_TYPES,
        message: "Acceptable types are: #{PROTOCOL_TYPES.join( ', ' )}"
    }

    validates_presence_of   :host
    validates_format_of     :host, with: /\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}\z/
    validates_uniqueness_of :host, scope: [:user_id, :port, :protocol]

    validates_presence_of     :port
    validates_numericality_of :port

    before_save :build_profile_override

    scope :verified, -> do
        joins(:verification).where( site_verifications: { state: :verified } )
    end
    scope :unverified, -> do
        joins(:verification).where.not( site_verifications: { state: :verified } )
    end

    def url
        u = "#{protocol}://#{host}"

        if (protocol == 'http' && port == 80) ||
            (protocol == 'https' && port == 443)
            return u
        end

        "#{u}:#{port}"
    end
    alias :to_s :url

    def scanned_at
        revisions.order( stopped_at: :desc ).limit(1).pluck(:stopped_at).first
    end

    def verified?
        verification.verified?
    end

    def unverified?
        verification.unverified?
    end

end
