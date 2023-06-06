# frozen_string_literal: true

module Broadcasts
  module Profiles
    class DestroyService < BaseService
      def initialize(profile_id:, user_id:)
        @profile_id = profile_id
        @user_id = user_id
      end

      def call
        return false if profile_id.blank? || user_id.blank?

        begin
          broadcast_to_profile_channel

          true
        rescue ActiveRecord::RecordNotFound
          false
        end
      end

      private

      attr_reader :profile_id, :user_id

      def user
        @user ||= User.find(user_id)
      end

      def params
        { profile_id: profile_id, action: action }
      end

      def action
        :destroy
      end
    end
  end
end
