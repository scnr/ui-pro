# frozen_string_literal: true

module Broadcasts
  module Devices
    class DestroyJob < ApplicationJob
      queue_as :anycable

      def perform(id)
        Broadcasts::Devices::DestroyService.call(device_id: id)
      end
    end
  end
end
