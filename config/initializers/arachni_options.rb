# Default options for Profile, SiteProfile and Setting.
#
# These will also act as defaults for the spawned processes in case they're
# missing from the RPC configuration.
#
# We want conservative defaults, playing it safe.
#
# Somewhat reduced performance and **minimal** loss of coverage are acceptable
# if it means less stressing of the remote server, less resource utilization
# and less chance of processing redundant workload.

# Safeguard against broken relative links leading to a loop of 404s, each
# adding +1 depth.
#
# It's rare and it will still suck, but at least the scan won't take forever.
#
# Also, limiting the scan to 10 directories deep shouldn't result in any
# appreciable loss of coverage 90+% of the time.
Arachni::Options.scope.directory_depth_limit = 10

# A little more conservative than the default, makes things faster.
Arachni::Options.scope.dom_depth_limit = 4

# Safeguard against redundant pages like galleries, blog posts etc.
#
# Watch out for sites where routing is based on a URL parameter?
# Like: ?content=index
Arachni::Options.scope.auto_redundant_paths  = 10

# We do this so that the values that will be used will appear in the UI.
Arachni::Options.input.values = Arachni::Options.input.default_values.dup
Arachni::Options.input.default_values.clear

# Significantly more conservative than the default, makes things faster and
# it's still a valid assumption that after 5s the game is over.
Arachni::Options.http.request_timeout = 5_000

# A little more conservative than the default, will result in decreased
# job-processing performance but when taking into account the rest of the
# option updates the overall scan will end up being faster.
#
# Plus, less resource utilization is a very good thing for Pro, means more
# parallel scans.
Arachni::Options.browser_cluster.pool_size = 4

# A little more conservative than the default, makes things faster.
# Also, if a job takes more than 10s, screw it.
Arachni::Options.browser_cluster.job_timeout   = 10

# Images almost never play a part so skip them.
Arachni::Options.browser_cluster.ignore_images = true
