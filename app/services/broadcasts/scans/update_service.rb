# frozen_string_literal: true

module Broadcasts
  module Scans
    class UpdateService < BaseService
      def initialize(scan_id:)
        @scan_id = scan_id
      end

      private

      attr_reader :scan_id

      def scan
        @scan ||= Scan.find(scan_id)
      end

      def action
        :update
      end
    end
  end
end
