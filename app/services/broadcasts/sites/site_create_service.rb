# frozen_string_literal: true

module Broadcasts
  module Sites
    class SiteCreateService < BaseService
      def initialize(site_id:)
        @site_id = site_id
      end

      private

      attr_reader :site_id

      def user
        @user ||= site.user
      end

      def site
        @site ||= Site.find(site_id)
      end

      def action
        :create
      end
    end
  end
end
