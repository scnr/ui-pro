# frozen_string_literal: true

module Broadcasts
  module Profiles
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

      def profile
        @profile ||= scan.try(:profile)
      end
    end
  end
end
