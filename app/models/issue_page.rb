class IssuePage < ActiveRecord::Base
    has_one :request,  as: :requestable, class_name: 'HttpRequest',
            dependent: :destroy

    has_one :response, as: :responsable, class_name: 'HttpResponse',
            dependent: :destroy

    has_one :dom,      class_name: 'IssuePageDom',
            dependent: :destroy

    belongs_to :issue, optional: true
    belongs_to :sitemap_entry, counter_cache: true, optional: true

    after_create_commit :broadcast_create_job

    def self.create_from_engine( page, options = {} )
        create({
            dom:      IssuePageDom.create_from_engine( page.dom ),
            request:  HttpRequest.create_from_engine(page.request ),
            response: HttpResponse.create_from_engine( page.response )
        }.merge(options))
    end

    private

    def broadcast_create_job
        Broadcasts::ScanResults::UpdateJob.perform_later(user_id)
    end

    def user_id
        return issue.site.user.id           if issue.present?
        return sitemap_entry.site.user.id   if sitemap_entry.present?
    end
end
