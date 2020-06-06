class Report < ActiveRecord::Base
    belongs_to :revision, optional: true
end
