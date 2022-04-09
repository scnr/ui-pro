setup = () ->
    if $('#scan-results-filter').exists()
        $('#scan-results-filter .check_boxes').change ->
            $('#scan-results-filter').submit();

jQuery setup
$(document).on( "turbo:load", setup )
