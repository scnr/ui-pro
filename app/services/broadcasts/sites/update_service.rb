# frozen_string_literal: true

module Broadcasts
  module Sites
    class UpdateService < BaseService
      def initialize(site_id:)
        @site_id = site_id
      end

      private

      attr_reader :site_id

      def site
        @site ||= Site.find(site_id)
      end

      def user
        @user ||= site.user
      end

      def action
        :update
      end
    end
  end
end
