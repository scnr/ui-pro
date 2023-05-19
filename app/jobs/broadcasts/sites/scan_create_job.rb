# frozen_string_literal: true

module Broadcasts
  module Sites
    class ScanCreateJob < ApplicationJob
      queue_as :default

      def perform(id)
        scan = find_scan(id)
        return if scan.blank?

        site = find_site(scan)
        return if site.blank?

        user = find_user(site)
        return if user.blank?

        broadcast_scan_create(user, site)
      end

      private

      def find_scan(id)
        Scan.find_by(id: id)
      end

      def find_site(scan)
        scan.site
      end

      def find_user(site)
        site.user
      end

      def broadcast_scan_create(user, site)
        SitesChannel.broadcast_to(
          user,
          site_id: site.id,
          html: render_site_partial(site),
          action: :update
        )
      end

      def render_site_partial(site)
        SitesController.render(partial: 'sites/site', locals: { site: site })
      end
    end
  end
end
