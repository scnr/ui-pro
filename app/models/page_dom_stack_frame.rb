class PageDomStackFrame < ActiveRecord::Base
    belongs_to :traceable, polymorphic: true
    has_one    :function, as: :with_dom_function,
               class_name: 'IssuePageDomFunction'
end
