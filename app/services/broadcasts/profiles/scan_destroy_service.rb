# frozen_string_literal: true

module Broadcasts
  module Profiles
    class ScanDestroyService < BaseService
      def initialize(user_id:, profile_id:)
        @user_id = user_id
        @profile_id = profile_id
      end

      private

      attr_reader :user_id, :profile_id

      def user
        @user ||= User.find(user_id)
      end

      def profile
        @profile ||= Profile.find(profile_id)
      end
    end
  end
end
