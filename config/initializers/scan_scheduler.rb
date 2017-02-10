# Don't run inside Rake tasks, spoecs or console.
if (!defined?( Rake ) || (defined?( Rake ) && Rake.application.top_level_tasks.empty?)) &&
    !defined?( RSpec ) &&
    !defined?( Rails::Console )

    ScanScheduler.start
end
