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

# Exclude files that won't contribute anything to the scan.
#
# The browsers will not check the scope of asset files, so these shouldn't
# mess with it, they should only narrow down the audit.
options.scope.exclude_file_extensions = %w(
gif bmp tif tiff jpg jpeg jpe pjpeg png ico psd xcf
mpg mpeg mpe 3gp avi flv mov mp4 swf vob wmv
mp3 wav wma mid m4a ogg flac
zip zipx tar gz 7z rar pkg deb rpm msi
bin cue dmg iso mdf vcd raw
exe apk app jar
ttf otf woff
css
js
)

# Document files are a tough call.
# There are checks that look for SSN and credit-card numbers and these files
# could expose them.
# options.scope.exclude_file_extensions.merge %w(
# pdf ps xls xlsx doc docx pps ppt pptx odt
# )

# Safeguard against broken relative links leading to a loop of 404s, each
# adding +1 depth.
#
# It's rare and it will still suck, but at least the scan won't take forever.
#
# Also, limiting the scan to 20 directories deep shouldn't result in any
# appreciable loss of coverage 90+% of the time.
options.scope.directory_depth_limit = 20

# A little more conservative than the default, makes things faster.
options.scope.dom_depth_limit = 4

# Safeguard against redundant pages like galleries, blog posts etc.
#
# Watch out for sites where routing is based on a URL parameter?
# Like: ?content=index
options.scope.auto_redundant_paths  = 20

# We do this so that the values that will be used will appear in the UI.
options.input.values = options.input.default_values.dup
options.input.default_values.clear

# Significantly more conservative than the default, makes things faster and
# it's still a valid assumption that after 5s the game is over.
options.http.request_timeout = 5_000

# A little more conservative than the default, will result in decreased
# job-processing performance but when taking into account the rest of the
# option updates the overall scan will end up being faster.
#
# Plus, less resource utilization is a very good thing for Pro, means more
# parallel scans.
options.browser_cluster.pool_size = 4

# A little more conservative than the default, makes things faster.
# Also, if a job takes more than 10s, screw it.
options.browser_cluster.job_timeout   = 10

# Images almost never play a part so skip them.
options.browser_cluster.ignore_images = true
