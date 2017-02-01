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

options = Arachni::Options

# Dev defaults, for comparison with other branches and Pro vs CLI.
options.audit.elements :forms, :links, :ui_forms, :ui_inputs

# Production defaults.
# options.audit.elements :forms, :links, :cookies, :ui_forms, :ui_inputs

# We do this so that the values that will be used will appear in the UI.
options.input.values = options.input.default_values.dup
options.input.default_values.clear

