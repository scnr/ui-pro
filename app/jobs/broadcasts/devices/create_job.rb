# frozen_string_literal: true

module Broadcasts
  module Devices
    class CreateJob < ApplicationJob
      queue_as :default

      def perform(id)
        Broadcasts::Devices::CreateService.call(device_id: id)
      end
    end
  end
end
