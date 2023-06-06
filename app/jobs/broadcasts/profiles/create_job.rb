# frozen_string_literal: true

module Broadcasts
  module Profiles
    class CreateJob < ApplicationJob
      queue_as :default

      def perform(id)
        Broadcasts::Profiles::CreateService.call(profile_id: id)
      end
    end
  end
end
