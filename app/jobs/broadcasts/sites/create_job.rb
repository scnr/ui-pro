# frozen_string_literal: true

module Broadcasts
  module Sites
    class CreateJob < ApplicationJob
      queue_as :default

      def perform(id)
        Broadcasts::Sites::CreateService.call(site_id: id)
      end
    end
  end
end
