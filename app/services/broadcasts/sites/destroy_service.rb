# frozen_string_literal: true

module Broadcasts
  module Sites
    class DestroyService < BaseService
      def initialize(site_id:, user_id:)
        @site_id = site_id
        @user_id = user_id
      end

      def call
        return if site_id.blank? || user_id.blank?

        begin
          broadcast_to_site_channel

          true
        rescue ActiveRecord::RecordNotFound
          false
        end
      end

      private

      attr_reader :site_id, :user_id

      def params
        { site_id: site_id, action: action }
      end

      def user
        @user ||= User.find(user_id)
      end

      def action
        :destroy
      end
    end
  end
end
