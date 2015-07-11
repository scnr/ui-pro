class Revision < ActiveRecord::Base
    belongs_to :scan, counter_cache: true
    belongs_to :site, counter_cache: true
    has_many :issues,  dependent: :destroy
    has_many :fixed_issues,  class_name: 'Issue', foreign_key: 'fixed_by_revision_id'
    has_many :sitemap_entries

    validates_presence_of :scan

    before_save :set_index
    before_save :set_site

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

    def set_index
        self.index ||= scan.revisions.count + 1
    end

    def set_site
        self.site = scan.site
    end
end
