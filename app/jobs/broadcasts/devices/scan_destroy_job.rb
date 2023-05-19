# frozen_string_literal: true

module Broadcasts
  module Devices
    class ScanDestroyJob < ApplicationJob
      queue_as :default

      def perform(user_id, device_id)
        Broadcasts::Devices::ScanDestroyService.call(user_id: user_id, device_id: device_id)
      end
    end
  end
end
