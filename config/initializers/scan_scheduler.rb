# Don't run inside Rake tasks.
if !defined?( Rake ) && !defined?( RSpec )
    ScanScheduler.start
end
