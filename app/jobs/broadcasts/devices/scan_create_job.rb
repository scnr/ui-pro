# frozen_string_literal: true

module Broadcasts
  module Devices
    class ScanCreateJob < ApplicationJob
      queue_as :default

      def perform(id)
        Broadcasts::Devices::ScanCreateService.call(scan_id: id)
      end
    end
  end
end
