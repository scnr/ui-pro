# frozen_string_literal: true

module Broadcasts
  module Devices
    class IssueCreateJob < ApplicationJob
      queue_as :default

      def perform(id)
        issue = find_issue(id)
        return if issue.blank?

        user = find_user(issue)
        return if user.blank?

        device = find_device(issue.scan)
        return if device.blank?

        broadcast_issue_create(user, device, device.scans)
      end

      private

      def find_issue(id)
        Issue.find_by(id: id)
      end

      def find_user(issue)
        issue.site.try(:user)
      end

      def find_device(scan)
        scan.try(:device)
      end

      def broadcast_issue_create(user, device, scans)
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
