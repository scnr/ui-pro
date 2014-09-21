class IssuePage < ActiveRecord::Base
    has_one :request,  as: :requestable, class_name: 'HttpRequest'
    has_one :response, as: :responsable, class_name: 'HttpResponse'
    has_one :dom,      class_name: 'IssuePageDom'
    has_one :issue

    def self.create_from_arachni( page )
        create(
            dom:      IssuePageDom.create_from_arachni( page.dom ),
            request:  HttpRequest.create_from_arachni( page.request ),
            response: HttpResponse.create_from_arachni( page.response )
        )
    end
end
