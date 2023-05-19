# frozen_string_literal: true

module Broadcasts
  module Sites
    class IssueCreateJob < ApplicationJob
      queue_as :default

      def perform(id)
        Broadcasts::Sites::IssueCreateService.call(issue_id: id)
      end
    end
  end
end
