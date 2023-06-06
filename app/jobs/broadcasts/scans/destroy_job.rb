# frozen_string_literal: true

module Broadcasts
  module Scans
    class DestroyJob < ApplicationJob
      queue_as :default

      def perform(scan_id, user_id)
        Broadcasts::Scans::DestroyService.call(scan_id: scan_id, user_id: user_id)
      end
    end
  end
end
