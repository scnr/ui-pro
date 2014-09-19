class IssuePage < ActiveRecord::Base
    has_one :request,  as: :requestable, class_name: 'HttpRequest'
    has_one :response, as: :responsable, class_name: 'HttpResponse'
    has_one :dom,      class_name: 'IssuePageDom'
    has_one :issue
end
