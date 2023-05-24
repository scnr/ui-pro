# frozen_string_literal: true

module Broadcasts
  module Scans
    class CreateService < BaseService
      def initialize(scan_id:)
        @scan_id = scan_id
      end

      private

      attr_reader :scan_id

      def scan
        @scan ||= Scan.find(scan_id)
      end

      def action
        :create
      end
    end
  end
end
