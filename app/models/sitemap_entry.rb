class SitemapEntry < ActiveRecord::Base
    belongs_to :site
    belongs_to :revision

    has_many :issues

    scope :with_issues,    -> { joins(:issues).where.not( issues: { sitemap_entry_id: nil } ).uniq }
    scope :without_issues, -> { joins(:issues).where( issues: { sitemap_entry_id: nil } ).uniq }
    default_scope { order :url }
end
