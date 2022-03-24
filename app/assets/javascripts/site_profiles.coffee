# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

findLabelForByText = ( string ) ->
    $('#platforms-list label').filter( ->
        $.trim(this.firstChild.nodeValue) == $.trim(string);
    ).attr('for')

selectPlatforms = ( platforms ) ->
    $('#platforms-list .check_boxes').prop('checked', '')

    for platform in platforms.split( /,/ )
        $('#' + findLabelForByText(platform)).prop('checked', 'checked')

setup = () ->
    $('.profile-form button.platforms-preset').click ->
        selectPlatforms $(this).html()
        false
    $('button#site_profile-submit').click ->
        $('.profile-form').submit()
    $('button#site_profile-submit-and-apply').click ->
        $('.profile-form #apply').val( 1 )
        $('.profile-form').submit()

jQuery setup
$(document).on( "turbo:load", setup )
