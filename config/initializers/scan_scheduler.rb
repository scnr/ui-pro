# Don't run inside Rake tasks.
if !defined?( Rake ) && !defined?( RSpec ) && !defined?( Rails::Console )
    ScanScheduler.start
end
