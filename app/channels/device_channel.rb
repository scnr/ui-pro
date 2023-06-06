# frozen_string_literal: true

class DeviceChannel < ApplicationCable::Channel
  def subscribed
    stream_for :devices
  end
end
