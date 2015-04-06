json.array!(@user_agents) do |user_agent|
  json.extract! user_agent, :id, :http_user_agent, :browser_cluster_screen_width, :browser_cluster_screen_height
  json.url user_agent_url(user_agent, format: :json)
end
