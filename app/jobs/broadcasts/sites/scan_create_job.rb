# frozen_string_literal: true

module Broadcasts
  module Sites
    class ScanCreateJob < ApplicationJob
      queue_as :default

      def perform(id)
        Broadcasts::Sites::ScanCreateService.call(scan_id: id)
      end
    end
  end
end
