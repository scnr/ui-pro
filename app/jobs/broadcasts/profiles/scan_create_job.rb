# frozen_string_literal: true

module Broadcasts
  module Profiles
    class ScanCreateJob < ApplicationJob
      queue_as :default

      def perform(id)
        Broadcasts::Profiles::ScanCreateService.call(scan_id: id)
      end
    end
  end
end
