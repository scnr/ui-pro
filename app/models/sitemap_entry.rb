class SitemapEntry < ActiveRecord::Base
    belongs_to :site, counter_cache: true, optional: true
    belongs_to :scan, counter_cache: true, optional: true
    belongs_to :revision, counter_cache: true, optional: true

    has_many :issues
    has_many :input_vectors
    has_many :pages, class_name: 'IssuePage', foreign_key: 'sitemap_entry_id'

    scope :coverage, -> do
        select(:revision_id, :coverage, :digest, :url, :code).distinct.
            where( code: 200, coverage: true )
    end
    scope :with_issues, -> { joins(:issues).where.not( issues: { sitemap_entry_id: nil } ) }
    scope :without_issues, -> { joins(:issues).where( issues: { sitemap_entry_id: nil } ) }
    default_scope { includes(:issues).order(:url).distinct }

    before_save :set_owners
    before_save :set_digest

    def self.with_issues_in_revision( revision )
        joins(:issues).where( issues: revision.issues )
    end

    def path
        URI( url ).path
    end

    def set_owners
        if revision
            self.scan = revision.scan
        end

        if scan
            self.site = scan.site
        end

        true
    end

    def set_digest
        self.digest = url.persistent_hash
    end
end
