json.array!(@schedules) do |schedule|
    json.extract! schedule, :id, :month_frequency, :day_frequency, :start_at, :stop_after
    json.url schedule_url(schedule, format: :json)
end
