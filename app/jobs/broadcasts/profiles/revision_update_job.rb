# frozen_string_literal: true

module Broadcasts
  module Profiles
    class RevisionUpdateJob < ApplicationJob
      queue_as :default

      def perform(id)
        Broadcasts::Profiles::RevisionUpdateService.call(revision_id: id)
      end
    end
  end
end
