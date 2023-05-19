# frozen_string_literal: true

module Broadcasts
  module Sites
    class RevisionUpdateService < BaseService
      def initialize(revision_id:)
        @revision_id = revision_id
      end

      private

      attr_reader :revision_id

      def revision
        @revision ||= Revision.find(revision_id)
      end

      def user
        @user ||= site.try(:user)
      end

      def site
        @site ||= revision.site
      end

      def action
        :update
      end
    end
  end
end
