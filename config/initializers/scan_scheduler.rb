if !Rails.env.test?
    ScanScheduler.start
end
