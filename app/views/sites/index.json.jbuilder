json.array!(@sites) do |site|
    json.extract! site, :id, :protocol, :host, :port
    json.url site_url(site, format: :json)
end
