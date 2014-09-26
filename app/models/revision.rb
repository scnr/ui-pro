class Revision < ActiveRecord::Base
    belongs_to :scan, counter_cache: true
    has_many :issues,  dependent: :destroy
    has_many :sitemap_entries

    def index
        scan.revisions.index( self ) + 1
    end
end
