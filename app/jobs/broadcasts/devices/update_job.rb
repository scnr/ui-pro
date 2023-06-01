# frozen_string_literal: true

module Broadcasts
  module Devices
    class UpdateJob < ApplicationJob
      queue_as :default

      def perform(id)
        Broadcasts::Devices::UpdateService.call(device_id: id)
      end
    end
  end
end
