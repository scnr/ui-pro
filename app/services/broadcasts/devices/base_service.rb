# frozen_string_literal: true

module Broadcasts
  module Devices
    class BaseService < ApplicationService
      def call
        begin
          return false if device.blank?

          broadcast_to_device_channel

          true
        rescue ActiveRecord::RecordNotFound
          false
        end
      end

      private

      def device
        nil
      end

      def action
        nil
      end

      def scans
        @scans ||= device.try(:scans) || []
      end

      def broadcast_to_device_channel
        DeviceChannel.broadcast_to(:devices, **params)
      end

      def params
        {
          device_id: device.id,
          action: action,
          sidebar_html: render_sidebar_partial,
          device_html: render_device_partial
        }
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

      def render_device_partial
        DevicesController.render(partial: 'devices/row_field', locals: { device: device })
      end
    end
  end
end
