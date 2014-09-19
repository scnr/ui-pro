class PageDomStackFrame < ActiveRecord::Base
    belongs_to :traceable, polymorphic: true
    has_one    :function, as: :with_func, class_name: 'PageDomFunction'
end
