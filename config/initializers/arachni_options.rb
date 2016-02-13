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

# Exclude files that won't contribute anything to the scan.
options.scope.exclude_file_extensions = {
    # Media
    image:       %w(
        gif bmp tif tiff jpg jpeg jpe pjpeg png ico psd xcf 3dm max svg eps drw
        ai
    ),
    video:       %w(asf rm mpg mpeg mpe 3gp 3g2  avi flv mov mp4 swf vob wmv),
    audio:       %w(aif mp3 mpa ra wav wma mid m4a ogg flac),

    # Generic data
    archive:     %w(zip zipx tar gz 7z rar bz2),
    disk:        %w(bin cue dmg iso mdf vcd raw),

    # Executables -- or thereabouts.
    application: %w(exe apk app jar pkg deb rpm msi),

    # Assets
    #
    # The browsers will not check the scope for asset files, so these shouldn't
    # mess with it, they should only narrow down the audit.
    font:        %w(ttf otf woff fon fnt),
    stylesheet:  %w(css),
    script:      %w(js),

    # Documents
    #
    # Allow rtf, ps, xls, doc, ppt, ppts since they can contain greppable text.
    document:    %w(pdf docx xlsx pptx odt odp),
}.values.flatten.uniq

# Safeguard against broken relative links leading to a loop of 404s, each
# adding +1 depth.
#
# It's rare and it will still suck, but at least the scan won't take forever.
#
# Also, limiting the scan to 10 directories deep shouldn't result in any
# appreciable loss of coverage 90+% of the time.
options.scope.directory_depth_limit = 10

# A little more conservative than the default, makes things faster.
options.scope.dom_depth_limit = 4

# Safeguard against redundant pages like galleries, blog posts etc.
#
# Watch out for sites where routing is based on a URL parameter?
# Like: ?content=index
options.scope.auto_redundant_paths = 15

# We do this so that the values that will be used will appear in the UI.
options.input.values = options.input.default_values.dup
options.input.default_values.clear

# Significantly more conservative than the default, makes things slower but
# we've got to play it safe, cause less stress on the servers.
options.http.request_concurrency = 14

# Significantly more conservative than the default and tightly coupled with
# request_concurrency in turn of performance outcome.
#
# Since request_concurrency has been lowered we can lower this too to lower
# RAM usage without further performance impact.
options.http.request_queue_size = 50

# Significantly more conservative than the default, makes things faster and
# it's still a valid assumption that after 5s the game is over.
options.http.request_timeout = 5_000

# Play it safe, assume slow server and a page that loads many un-cacheable resources.
options.browser_cluster.job_timeout = options.http.request_timeout * 10

# Images almost never play a part so skip them.
options.browser_cluster.ignore_images = true
