# frozen_string_literal: true

module Broadcasts
  module Sites
    class SiteCreateJob < ApplicationJob
      queue_as :default

      def perform(id)
        Broadcasts::Sites::SiteCreateService.call(site_id: id)
      end
    end
  end
end
