class SiteDeleteJob < ApplicationJob
    queue_as :default

    def perform( site )
      site.destroying!
      site.destroy
      SitesChannel.broadcast_to(site.user, site_id: site.id, action: :destroy)
    end
end
