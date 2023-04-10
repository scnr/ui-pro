Rails.configuration.after_initialize do
Revision.active.each do |revision|
    begin
        ScanScheduler.instance_for( revision )
    rescue ScanScheduler::Helpers::Instance::Error::InstanceNotFound
        revision.failed!
        revision.stopped_at = Time.now
        revision.save
    end
end
end
