class Revision < ActiveRecord::Base
    include RevisionStates

    serialize :rpc_options, Hash

    has_one  :performance_snapshot, dependent: :destroy,
             foreign_key: 'revision_current_id'

    belongs_to :scan, counter_cache: true
    belongs_to :site, counter_cache: true

    has_many :issues,  dependent: :destroy
    has_many :reviewed_issues,  class_name: 'Issue',
             foreign_key: 'reviewed_by_revision_id'

    has_many :sitemap_entries, dependent: :destroy

    has_many :performance_snapshots, -> { order id: :asc }, dependent: :destroy

    validates_presence_of :scan

    before_create :ensure_performance_snapshot

    before_save :set_index
    before_save :set_site
    before_save :set_rpc_options

    scope :in_progress, -> do
        where.not( started_at: nil ).where( stopped_at: nil )
    end

    def self.last_performed
        where.not( stopped_at: nil ).order( stopped_at: :desc ).limit(1).first
    end

    def self.last_performed_at
        where.not( stopped_at: nil ).order( stopped_at: :desc ).limit(1).
            pluck(:stopped_at).first
    end

    def self.in_progress?
        in_progress.any?
    end

    def duration
        return if !started_at

        (stopped_at || Time.zone.now) - started_at
    end

    def stopped?
        !!stopped_at
    end

    def performed_at
        stopped_at
    end

    def in_progress?
        started_at && !stopped_at
    end

    def to_s
        "#{index.ordinalize} revision"
    end

    private

    def set_rpc_options
        return if self.rpc_options.any?
        self.rpc_options = scan.rpc_options
    end

    def set_index
        self.index ||= scan.revisions.count + 1
    end

    def set_site
        self.site = scan.site
    end

    def ensure_performance_snapshot
        self.performance_snapshot ||= build_performance_snapshot
    end
end
