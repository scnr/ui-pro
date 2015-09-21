# Default options for SiteProfile and Setting.
# These will also act as defaults for the spawned processes.
#
# We want conservative defaults, playing it safe.
# Somewhat reduced performance and **minimal** loss of coverage are acceptable
# if it means less stressing of the remote server, less resource utilization
# and less chance of processing redundant workload.

Arachni::Options.scope.auto_redundant_paths = 10

Arachni::Options.input.values = Arachni::Options.input.default_values.dup
Arachni::Options.input.default_values.clear

Arachni::Options.http.request_timeout = 5_000

Arachni::Options.browser_cluster.pool_size     = 4
Arachni::Options.browser_cluster.job_timeout   = 10
Arachni::Options.browser_cluster.ignore_images = true
