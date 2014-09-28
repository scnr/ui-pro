class Revision < ActiveRecord::Base
    belongs_to :scan, counter_cache: true
    has_many :issues,  dependent: :destroy
    has_many :sitemap_entries, counter_cache: true

    after_create :set_index

    def set_index
        self.index = scan.revisions.count
    end
end
