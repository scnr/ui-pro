# frozen_string_literal: true

module Broadcasts
  module Devices
    class BaseService < ApplicationService
      def call
        begin
          return false if user.blank? || device.blank?

          broadcast_to_device_channel

          true
        rescue ActiveRecord::RecordNotFound
          false
        end
      end

      private

      def broadcast_to_device_channel
        DeviceChannel.broadcast_to(
          user,
          device_id: device.id,
          scans_count: scans.count,
          sidebar_html: render_sidebar_partial
        )
      end

      def render_sidebar_partial
        DevicesController.render(
          partial: 'shared/sidebar_scans',
          locals: {
            scans: scans,
            with_site: true,
            with_count: true
          }
        )
      end

      def user
        nil
      end

      def device
        nil
      end

      def scans
        @scans ||= device.try(:scans) || []
      end
    end
  end
end
