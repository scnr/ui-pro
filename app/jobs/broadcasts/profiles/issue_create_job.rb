# frozen_string_literal: true

module Broadcasts
  module Profiles
    class IssueCreateJob < ApplicationJob
      queue_as :default

      def perform(id)
        Broadcasts::Profiles::IssueCreateService.call(issue_id: id)
      end
    end
  end
end
