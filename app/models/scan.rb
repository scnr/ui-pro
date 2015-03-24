class Scan < ActiveRecord::Base
    belongs_to :site
    belongs_to :profile

    has_one :schedule, autosave: true, dependent: :destroy
    accepts_nested_attributes_for :schedule

    has_many :revisions, dependent: :destroy
    has_many :issues, through: :revisions
    has_many :sitemap_entries, through: :revisions

    validates_associated    :schedule

    validates_presence_of   :name
    validates_uniqueness_of :name, scope: :site

    validates_presence_of   :site
    validates_presence_of   :profile

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
        options.merge!( 'authorized_by' => site.user.email )
        options
    end

end
