# frozen_string_literal: true

module Broadcasts
  module Scans
    class BaseService < ApplicationService
      DEFAULT_TABLE_ROW_PATH = 'scans/tables/row_fields'
      SCHEDULED_TABLE_ROW_PATH = 'scans/tables/schedule/row_field'

      def call
        begin
          return false if user.blank? || scan.blank?

          broadcast_to_scan_channel

          true
        rescue ActiveRecord::RecordNotFound
          false
        end
      end

      private

      def action
        nil
      end

      def scan
        nil
      end

      def broadcast_to_scan_channel
        ScanChannel.broadcast_to(user, **params)
      end

      def params
        { scan_id: scan.id, scan_html: render_scan_partial, action: action, status: status }
      end

      def render_scan_partial
        ScansController.render(partial: partial_path, locals: partial_params)
      end

      def partial_path
        scan.scheduled? ? SCHEDULED_TABLE_ROW_PATH : DEFAULT_TABLE_ROW_PATH
      end

      def partial_params
        { scan: scan, site: site, with_status: with_status? }
      end

      def with_status?
        !scan.suspended?
      end

      def user
        @user ||= site.try(:user)
      end

      def site
        @site ||= scan.site
      end

      def status
        @status ||= retrieve_status
      end

      def retrieve_status
        return :scheduled if scan.scheduled?
        return :suspended if scan.suspended?
        return :active    if scan.active?
        return :finished  if scan.finished?
      end
    end
  end
end
