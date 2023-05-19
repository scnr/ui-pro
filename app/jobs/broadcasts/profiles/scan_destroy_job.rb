# frozen_string_literal: true

module Broadcasts
  module Profiles
    class ScanDestroyJob < ApplicationJob
      queue_as :default

      def perform(user_id, profile_id)
        Broadcasts::Profiles::ScanDestroyService.call(user_id: user_id, profile_id: profile_id)
      end
    end
  end
end
