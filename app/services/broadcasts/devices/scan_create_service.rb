# frozen_string_literal: true

module Broadcasts
  module Devices
    class ScanCreateService < BaseService
      def initialize(scan_id:)
        @scan_id = scan_id
      end

      private

      attr_reader :scan_id

      def scan
        @scan ||= Scan.find(scan_id)
      end

      def user
        @user ||= scan.site.try(:user)
      end

      def device
        @device ||= scan.device
      end
    end
  end
end
