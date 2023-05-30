# frozen_string_literal: true

module Broadcasts
  module Scans
    class CreateJob < ApplicationJob
      queue_as :anycable

      def perform(id)
        Broadcasts::Scans::CreateService.call(scan_id: id)
      end
    end
  end
end
