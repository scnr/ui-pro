class IssuePageDomTransition < ActiveRecord::Base
    serialize :options, Hash

    belongs_to :dom, class_name: 'IssuePageDom', foreign_key: 'issue_page_dom_id'

    def event
        super.to_sym
    end

    def self.create_from_arachni( transition )
        create(
            element: transition.element.to_s,
            event:   transition.event,
            time:    transition.time,
            options: transition.options
        )
    end
end
