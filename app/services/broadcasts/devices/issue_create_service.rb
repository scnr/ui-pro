# frozen_string_literal: true

module Broadcasts
  module Devices
    class IssueCreateService < BaseService
      def initialize(issue_id:)
        @issue_id = issue_id
      end

      private

      attr_reader :issue_id

      def issue
        @issue ||= Issue.find(issue_id)
      end

      def user
        @user ||= issue.site.try(:user)
      end

      def scan
        @scan ||= issue.try(:scan)
      end

      def device
        @device ||= scan.try(:device)
      end
    end
  end
end
