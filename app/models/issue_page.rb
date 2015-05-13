class IssuePage < ActiveRecord::Base
    has_one :request,  as: :requestable, class_name: 'HttpRequest',
            dependent: :destroy

    has_one :response, as: :responsable, class_name: 'HttpResponse',
            dependent: :destroy

    has_one :dom,      class_name: 'IssuePageDom',
            dependent: :destroy

    belongs_to :issue
    belongs_to :sitemap_entry, counter_cache: true

    def self.create_from_arachni( page, options = {} )
        create({
            dom:      IssuePageDom.create_from_arachni( page.dom ),
            request:  HttpRequest.create_from_arachni( page.request ),
            response: HttpResponse.create_from_arachni( page.response )
        }.merge(options))
    end
end
