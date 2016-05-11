# Don't run inside Rake tasks.
if (defined?( Rake ) && Rake.application.top_level_tasks.empty?) &&
    !defined?( RSpec ) &&
    !defined?( Rails::Console )

    ScanScheduler.start
end
