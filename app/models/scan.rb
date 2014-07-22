class Scan < ActiveRecord::Base
    belongs_to :site
    belongs_to :profile

    validates_presence_of   :name
    validates_uniqueness_of :name, scope: :site

    validates_presence_of   :profile
end
