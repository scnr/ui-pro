# frozen_string_literal: true

module Broadcasts
  module Devices
    class RevisionUpdateJob < ApplicationJob
      queue_as :default

      def perform(id)
        revision = find_revision(id)
        return if revision.blank?

        device = find_device(revision)
        return if device.blank?

        user = find_user(revision)
        return if user.blank?

        broadcast_revision_create(user, device, device.scans)
      end

      private

      def find_revision(id)
        Revision.find_by(id: id)
      end

      def find_device(revision)
        revision.scan.try(:device)
      end

      def find_user(revision)
        revision.site.try(:user)
      end

      def broadcast_revision_create(user, device, scans)
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
