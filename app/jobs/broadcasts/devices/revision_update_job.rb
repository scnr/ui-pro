# frozen_string_literal: true

module Broadcasts
  module Devices
    class RevisionUpdateJob < ApplicationJob
      queue_as :default

      def perform(id)
        Broadcasts::Devices::RevisionUpdateService.call(revision_id: id)
      end
    end
  end
end
