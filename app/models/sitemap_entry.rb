class SitemapEntry < ActiveRecord::Base
    belongs_to :site
    belongs_to :revision

    has_many :issues

    scope :with_issues, -> { joins(:issues).where.not( issues: { sitemap_entry_id: nil } ) }
    scope :without_issues, -> { joins(:issues).where( issues: { sitemap_entry_id: nil } ) }
    default_scope { includes(:issues).order(:url).uniq }

    def self.with_issues_in_revision( revision )
        joins(:issues).where( issues: revision.issues )
    end
end
