# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

frequency_format = ->
    $('#scan_schedule_attributes_frequency_format').val()

schedule_params = ->
    params = {
        'start_at(1i)':     $('#scan_schedule_attributes_start_at_1i').val(),
        'start_at(2i)':     $('#scan_schedule_attributes_start_at_2i').val(),
        'start_at(3i)':     $('#scan_schedule_attributes_start_at_3i').val(),
        'start_at(4i)':     $('#scan_schedule_attributes_start_at_4i').val(),
        'start_at(5i)':     $('#scan_schedule_attributes_start_at_5i').val(),
        'frequency_base':   $('#scan_schedule_attributes_frequency_base').val(),
        'day_frequency':    $('#scan_schedule_attributes_day_frequency').val(),
        'month_frequency':  $('#scan_schedule_attributes_month_frequency').val(),
        'frequency_cron':   $('#scan_schedule_attributes_frequency_cron').val(),
        'frequency_format': frequency_format()
    }

    for k, v of params
        continue if v.length != 0
        params[k] = null

    params

update_schedule_preview = ->
    $.get $('#scan-form-schedule-preview').data('path') + '/preview_schedule',
        schedule_params(),
        ( data ) ->
            $('#scan-form-schedule-preview').html data

form_setup = () ->
    # Set the default, on-load frequency format type based on the active tab.
    $('#scan_schedule_attributes_frequency_format').val(
        $('div.format-tabs div.tab-pane.active').attr('id')
    );

    update_schedule_preview()

    $('.update_schedule_preview').change ->
        update_schedule_preview()

    $('div.format-tabs a[data-toggle="tab"]').click ->
        $('#scan_schedule_attributes_frequency_format').val(
            $(this).attr('href').replace( '#', '' )
        )

        update_schedule_preview()

setup = () ->
    if $('.scan-form').exists()
        form_setup()

jQuery setup
