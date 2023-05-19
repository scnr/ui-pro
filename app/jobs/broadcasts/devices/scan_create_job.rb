# frozen_string_literal: true

module Broadcasts
  module Devices
    class ScanCreateJob < ApplicationJob
      queue_as :default

      def perform(id)
        scan = find_scan(id)
        return if scan.blank?

        user = find_user(scan)
        return if user.blank?

        device = find_device(scan)
        return if device.blank?

        broadcast_scan_create(user, device, device.scans)
      end

      private

      def find_scan(id)
        Scan.find_by(id: id)
      end

      def find_user(scan)
        scan.site.try(:user)
      end

      def find_device(scan)
        scan.device
      end

      def broadcast_scan_create(user, device, scans)
        DeviceChannel.broadcast_to(
          user,
          device_id: device.id,
          scans_count: scans.count,
          sidebar_html: render_sidebar_partial(scans)
        )
      end

      def render_sidebar_partial(scans)
        DevicesController.render(
          partial: 'shared/sidebar_scans',
          locals: {
            scans: scans,
            with_site: true,
            with_count: true
          }
        )
      end
    end
  end
end
