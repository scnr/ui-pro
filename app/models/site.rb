class Site < ActiveRecord::Base
    PROTOCOL_TYPES = %w(http https)

    enum protocol: [ :http, :https ]

    belongs_to :user
    has_and_belongs_to_many :users

    has_one :profile, autosave: true, dependent: :destroy,
            foreign_key: 'site_id', class_name: 'SiteProfile'
    accepts_nested_attributes_for :profile

    has_many :scans, dependent: :destroy
    has_many :schedules, through: :scans
    has_many :revisions, through: :scans
    has_many :issues, through: :scans

    has_many :roles, dependent: :destroy, foreign_key: 'site_id',
             class_name: 'SiteRole'

    has_many :sitemap_entries, dependent: :destroy

    validates_presence_of :protocol

    validates_presence_of   :host
    validates_format_of     :host, with: /\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}\z/
    validates_uniqueness_of :host, scope: [:user_id, :port, :protocol]

    validates_presence_of     :port
    validates_numericality_of :port

    after_create :create_guest_role
    before_save  :ensure_profile

    def url
        u = "#{protocol}://#{host}"

        if (protocol == 'http' && port == 80) ||
            (protocol == 'https' && port == 443)
            return u
        end

        "#{u}:#{port}"
    end
    alias :to_s :url

    def scanned_or_being_scanned?
        revisions.where.not( started_at: nil ).any?
    end

    def being_scanned?
        revisions.in_progress?
    end

    def revision_in_progress
        return if revisions.size == 0
        revisions.includes(:scan).in_progress.first
    end

    def scanned?
        !!last_scanned_at
    end

    def last_scanned_at
        revisions.last_performed_at
    end

    def https?
        protocol == 'https'
    end

    private

    def ensure_profile
        self.profile ||= build_profile
    end

    def create_guest_role
        self.roles.create(
            name:       'Guest',
            login_type: 'none'
        )
    end
end
