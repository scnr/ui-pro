class Revision < ActiveRecord::Base
    belongs_to :scan

    def index
        scan.revisions.index( self ) + 1
    end
end
