# frozen_string_literal: true

module Broadcasts
  module Devices
    class ScanDestroyService < BaseService
      def initialize(user_id:, device_id:)
        @user_id = user_id
        @device_id = device_id
      end

      private

      attr_reader :user_id, :device_id

      def user
        @user ||= User.find(user_id)
      end

      def device
        @device ||= Device.find(device_id)
      end
    end
  end
end
