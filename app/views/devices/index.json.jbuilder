json.array!(@devices) do |device|
  json.extract! device, :id, :device_user_agent, :device_width, :device_height
  json.url device_url(device, format: :json)
end
