# frozen_string_literal: true

module Broadcasts
  module Scans
    class DestroyService < BaseService
      def initialize(scan_id:, user_id:)
        @scan_id = scan_id
        @user_id = user_id
      end

      def call
        return if scan_id.blank? || user_id.blank?

        begin
          broadcast_to_scan_channel

          true
        rescue ActiveRecord::RecordNotFound
          false
        end
      end

      private

      attr_reader :scan_id, :user_id

      def user
        @user ||= User.find(user_id)
      end

      def params
        { scan_id: scan_id, action: action }
      end

      def action
        :destroy
      end
    end
  end
end
