json.array!(@scans) do |scan|
    json.extract! scan, :id, :site_id, :name, :description, :profile_id, :schedule_id
    json.url site_scan_url(scan, format: :json)
end
