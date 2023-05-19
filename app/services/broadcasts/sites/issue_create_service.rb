# frozen_string_literal: true

module Broadcasts
  module Sites
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
        @user ||= site.user
      end

      def site
        @site ||= issue.revision.try(:site)
      end

      def action
        :update
      end
    end
  end
end
