# frozen_string_literal: true

module Broadcasts
  module ScanResults
    class UpdateService < ApplicationService
      def initialize(user_id:)
        @user_id = user_id
      end

      def call
        broadcast_to_scan_result_channel

        true
      rescue ActiveRecord::RecordNotFound
        false
      end

      private

      attr_reader :user_id

      def user
        @user ||= User.find(user_id)
      end

      def broadcast_to_scan_result_channel
        ScanResultChannel.broadcast_to(user, nil)
      end
    end
  end
end
