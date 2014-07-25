class Scan < ActiveRecord::Base
    belongs_to :site
    belongs_to :profile

    has_one :schedule, dependent: :destroy
    accepts_nested_attributes_for :schedule

    validates_associated    :schedule

    validates_presence_of   :name
    validates_uniqueness_of :name, scope: :site

    validates_presence_of   :profile

    scope :scheduled,   -> do
        joins(:schedule).where.not( schedules: { start_at: nil } )
    end
    scope :unscheduled, -> do
        where.not(
            Schedule.where( 'schedules.scan_id = scans.id' ).limit(1).arel.exists
        )
    end

    def scheduled?
        !!(schedule && schedule.start_at)
    end
end
