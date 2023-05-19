# frozen_string_literal: true

module Broadcasts
  module Sites
    class RevisionUpdateJob < ApplicationJob
      queue_as :default

      def perform(id)
        Broadcasts::Sites::RevisionUpdateService.call(revision_id: id)
      end
    end
  end
end
