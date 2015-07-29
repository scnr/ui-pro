class Scan < ActiveRecord::Base
    include ScanStates

    belongs_to :site, counter_cache: true
    belongs_to :site_role
    belongs_to :profile
    belongs_to :user_agent

    has_one :schedule, autosave: true, dependent: :destroy
    accepts_nested_attributes_for :schedule

    has_many :revisions, dependent: :destroy
    has_many :issues, dependent: :destroy
    has_many :sitemap_entries, dependent: :destroy

    validates_associated    :schedule

    validates_presence_of   :name
    validates_uniqueness_of :name, scope: :site

    validates_presence_of   :site
    validates_presence_of   :site_role
    validates_presence_of   :profile
    validates_presence_of   :user_agent

    # All scans should start with a schedule, which should be destroyed just
    # before they run.
    #
    # Unless they're recurring, in which case they get a `nil` `Schedule#start_at`,
    # which shall be updated once the scan finishes, based on the set freq.
    before_create :ensure_schedule

    scope :scheduled,   -> do
        includes(:schedule).where.not( schedules: { start_at: nil } ).
            order( 'schedules.start_at asc' )
    end
    scope :unscheduled, -> do
        includes(:schedule).where( schedules: { start_at: nil } ).order( id: :desc )
    end

    scope :with_revisions, -> { joins(:revisions).where.not( revisions: { id: nil } ) }

    def in_progress?
        return if revisions.size == 0
        last_revision.in_progress?
    end

    def last_performed_at
        return if revisions.size == 0
        last_revision.performed_at
    end

    def last_revision
        revisions.order( id: :desc ).first
    end

    def recurring?
        schedule.recurring?
    end

    def schedule_next
        schedule.schedule_next
    end

    def scheduled?
        !!schedule.start_at || recurring?
    end

    def to_s
        name
    end

    def path=( p )
        p = p.to_s
        super p.start_with?( '/' ) ? p : "/#{p}"
    end

    def url
        "#{site.url}#{path}"
    end

    def rpc_options
        options = profile.to_rpc_options

        profile_rpc_options = site.profile.to_rpc_options
        profile_rpc_options['scope'] ||= {}

        profile_exclude_path_patterns =
            profile_rpc_options['scope'].delete( 'exclude_path_patterns' ) || []
        profile_exclude_content_patterns =
            profile_rpc_options['scope'].delete( 'exclude_content_patterns' ) || []

        options.deep_merge!( profile_rpc_options )
        options.deep_merge!( user_agent.to_rpc_options )
        options.deep_merge!( Settings.to_rpc_options )

        site_role_rpc_options = site_role.to_rpc_options

        options['scope']                             ||= {}
        options['scope']['exclude_path_patterns']    ||= []
        options['scope']['exclude_content_patterns'] ||= []
        site_role_rpc_options['scope']               ||= {}
        profile_rpc_options['scope']                 ||= {}

        options['scope']['exclude_path_patterns'] |=
            site_role_rpc_options['scope'].delete( 'exclude_path_patterns' ) || []

        options['scope']['exclude_path_patterns']    |= profile_exclude_path_patterns
        options['scope']['exclude_content_patterns'] |= profile_exclude_content_patterns

        options.deep_merge!( site_role_rpc_options )

        options.merge!( 'authorized_by' => site.user.email )

        options['url'] = url

        options
    end

    private

    def ensure_schedule
        self.schedule ||= build_schedule
    end

end
