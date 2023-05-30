# frozen_string_literal: true

module Broadcasts
  module Profiles
    class UpdateJob < ApplicationJob
      queue_as :anycable

      def perform(id)
        Broadcasts::Profiles::UpdateService.call(profile_id: id)
      end
    end
  end
end
