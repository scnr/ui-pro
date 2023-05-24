# frozen_string_literal: true

module Broadcasts
  module Devices
    class CreateService < BaseService
      def initialize(device_id:)
        @device_id = device_id
      end

      private

      attr_reader :device_id

      def device
        @device ||= Device.find(device_id)
      end

      def action
        :create
      end
    end
  end
end
