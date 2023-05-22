# frozen_string_literal: true

class SiteRoleChannel < ApplicationCable::Channel
  def subscribed
    stream_for(current_user)
  end
end
