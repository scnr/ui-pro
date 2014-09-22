class Scan < ActiveRecord::Base
    belongs_to :plan
    belongs_to :site
    belongs_to :profile

    has_one :profile_override, as: :profile_overridable, autosave: true,
            dependent: :destroy
    accepts_nested_attributes_for :profile_override

    has_one :schedule, autosave: true, dependent: :destroy
    accepts_nested_attributes_for :schedule

    has_many :revisions, dependent: :destroy

    validates_associated    :profile_override
    validates_associated    :schedule

    validates_presence_of   :name
    validates_uniqueness_of :name, scope: :site

    validates_presence_of   :site
    validates_presence_of   :plan
    validates_presence_of   :profile

    before_save :build_profile_override

    scope :scheduled,   -> do
        joins(:schedule).where.not( schedules: { start_at: nil } )
    end
    scope :unscheduled, -> do
        where.not(
            Schedule.where( 'schedules.scan_id = scans.id' ).limit(1).arel.exists
        )
    end

    scope :with_revisions, -> { joins(:revisions).where( 'revisions.id IS NOT NULL' ) }

    def scheduled?
        !!(schedule && schedule.start_at)
    end

    def rpc_options
        options = profile.to_rpc_options
        options.deep_merge!( GlobalProfile.to_rpc_options )
        options.merge!( 'authorized_by' => site.user.email )

        # Order is important, we go from User (most generic) to Site (middle-ground)
        # to Scan (specialized).
        options.deep_merge!( site.user.profile_override.to_rpc_options )
        options.deep_merge!( site.profile_override.to_rpc_options )
        options.deep_merge!( profile_override.to_rpc_options )

        # Plan overrides trump all.
        options.deep_merge!( plan.profile_override.to_rpc_options )

        options
    end

end
