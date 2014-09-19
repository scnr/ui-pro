class PageDomFunction < ActiveRecord::Base
    belongs_to :with_func, polymorphic: true

    serialize :arguments, Array
end
