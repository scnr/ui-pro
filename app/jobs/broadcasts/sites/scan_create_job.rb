# frozen_string_literal: true

module Broadcasts
  module Sites
    class ScanCreateJob < ApplicationJob
      queue_as :default

      def perform(scan_id)
        scan = Scan.find_by(id: scan_id)
        return if scan.blank?

        site = scan.site
        return if site.blank?

        user = site.user
        return if user.blank?

        SitesChannel.broadcast_to(
          user,
          site_id: site.id,
          html: SitesController.render(partial: 'sites/site', locals: { site: site }),
          action: :update
        )
      end
    end
  end
end
