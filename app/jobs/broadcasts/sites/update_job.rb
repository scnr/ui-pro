# frozen_string_literal: true

module Broadcasts
  module Sites
    class UpdateJob < ApplicationJob
      queue_as :anycable

      def perform(id)
        Broadcasts::Sites::UpdateService.call(site_id: id)
      end
    end
  end
end
