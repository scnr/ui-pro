class SiteDeleteJob < ApplicationJob
    queue_as :default

    def perform( site )
      site.destroying!
      site.destroy

      Broadcasts::Sites::SiteDestroyService.call(site: site)
    end

end
