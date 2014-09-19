class IssuePageDomTransition < ActiveRecord::Base
    belongs_to :dom, class_name: 'IssuePageDom', foreign_key: 'issue_page_dom_id'
end
