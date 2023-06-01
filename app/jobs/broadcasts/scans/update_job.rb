# frozen_string_literal: true

module Broadcasts
  module Scans
    class UpdateJob < ApplicationJob
      queue_as :default

      def perform(id)
        Broadcasts::Scans::UpdateService.call(scan_id: id)
      end
    end
  end
end
