# frozen_string_literal: true

module Broadcasts
  module ScanResults
    class UpdateJob < ApplicationJob
      queue_as :default

      def perform(user_id)
        Broadcasts::ScanResults::UpdateService.call(user_id: user_id)
      end
    end
  end
end
