# frozen_string_literal: true

module Broadcasts
  module Profiles
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
        @user ||= revision.site.try(:user)
      end

      def profile
        @profile ||= revision.scan.try(:profile)
      end
    end
  end
end
