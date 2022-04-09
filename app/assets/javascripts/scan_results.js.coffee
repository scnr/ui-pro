setup = () ->
    if $('#scan-results-filter').exists()
        $('#scan-results-filter .check_boxes').change ->
            this.form.requestSubmit();

jQuery setup
$(document).on( "turbo:load", setup )
