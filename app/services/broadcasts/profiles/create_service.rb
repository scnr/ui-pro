# frozen_string_literal: true

module Broadcasts
  module Profiles
    class CreateService < BaseService
      def initialize(profile_id:)
        @profile_id = profile_id
      end

      private

      attr_reader :profile_id

      def profile
        @profile ||= Profile.find(profile_id)
      end

      def action
        :create
      end
    end
  end
end
