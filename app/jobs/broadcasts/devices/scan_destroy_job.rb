# frozen_string_literal: true

module Broadcasts
  module Devices
    class ScanDestroyJob < ApplicationJob
      queue_as :default

      def perform(device_id, user_id)
        user = find_user(user_id)
        return if user.blank?

        device = find_device(device_id)
        return if device.blank?

        broadcast_scan_destroy(user, device, device.scans)
      end

      private

      def find_user(id)
        User.find_by(id: id)
      end

      def find_device(id)
        Device.find_by(id: id)
      end

      def broadcast_scan_destroy(user, device, scans)
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
