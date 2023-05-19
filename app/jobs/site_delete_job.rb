class SiteDeleteJob < ApplicationJob
    queue_as :default

    def perform( site )
      site.destroying!
      site.destroy

      broadcast_to_sites_channel(site)
    end

    private

    def broadcast_to_sites_channel(site)
      SitesChannel.broadcast_to(site.user, site_id: site.id, action: :destroy)
    end
end
