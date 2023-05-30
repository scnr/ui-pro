# frozen_string_literal: true

module Broadcasts
  module Profiles
    class DestroyJob < ApplicationJob
      queue_as :anycable

      def perform(profile_id, user_id)
        Broadcasts::Profiles::DestroyService.call(profile_id: profile_id, user_id: user_id)
      end
    end
  end
end
