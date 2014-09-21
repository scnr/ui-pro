class IssuePageDomTransition < ActiveRecord::Base
    belongs_to :dom, class_name: 'IssuePageDom', foreign_key: 'issue_page_dom_id'

    def self.create_from_arachni( transition )
        create(
            element: transition.element.to_s,
            event:   transition.event,
            time:    transition.time
        )
    end
end
