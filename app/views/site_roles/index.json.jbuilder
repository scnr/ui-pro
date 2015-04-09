json.array!(@site_roles) do |site_role|
  json.extract! site_role, :id, :name, :description, :session_check_url, :session_check_pattern, :plugins
  json.url site_role_url(site_role, format: :json)
end
