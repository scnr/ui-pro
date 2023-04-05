class SiteDeleteJob < ApplicationJob
    queue_as :default

    def perform( site )
      site.destroying!
      site.destroy
    end
end
