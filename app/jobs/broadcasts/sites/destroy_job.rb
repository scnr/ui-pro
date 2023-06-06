# frozen_string_literal: true

module Broadcasts
  module Sites
    class DestroyJob < ApplicationJob
      queue_as :default

      def perform(site_id, user_id)
        Broadcasts::Sites::DestroyService.call(site_id: site_id, user_id: user_id)
      end
    end
  end
end
