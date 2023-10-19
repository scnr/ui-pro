# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

update_form = () ->
    is_checked = $('#setting_max_parallel_scans_auto').prop('checked')

    if is_checked
        $('#setting_max_parallel_scans').val(
            $('#setting_max_parallel_scans_auto').data('slots-total')
        )
        $('#max_parallel_scans-help-block').addClass( 'd-none' )
        $('#max_parallel_scans_auto-help-block').removeClass( 'd-none' )
    else
        $('#max_parallel_scans-help-block').removeClass( 'd-none' )
        $('#max_parallel_scans_auto-help-block').addClass( 'd-none' )

    $('#setting_max_parallel_scans').prop( 'disabled', is_checked )

form_setup = () ->
    update_form()
    $('#setting_max_parallel_scans_auto').click update_form

setup = () ->
    if $('#edit_setting_1').exists()
        form_setup()

jQuery setup
$(document).on( "turbo:load", setup )
