# frozen_string_literal: true

module Broadcasts
  module Devices
    class IssueCreateJob < ApplicationJob
      queue_as :default

      def perform(id)
        Broadcasts::Devices::IssueCreateService.call(issue_id: id)
      end
    end
  end
end
