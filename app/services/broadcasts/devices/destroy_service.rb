# frozen_string_literal: true

module Broadcasts
  module Devices
    class DestroyService < BaseService
      def initialize(device_id:)
        @device_id = device_id
      end

      def call
        return false if device_id.blank?

        begin
          broadcast_to_device_channel

          true
        rescue ActiveRecord::RecordNotFound
          false
        end
      end

      private

      attr_reader :device_id

      def params
        { device_id: device_id, action: action }
      end

      def action
        :destroy
      end
    end
  end
end
