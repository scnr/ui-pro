# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

searchChecks = ( val ) ->
    $(".profile-checks").show()

    if( val != '' )
        for token in val.split( /\s+/ )
            $(".profile-checks:not(:icontains(" + token + "))").hide()
    else
        $(".profile-checks").show()

findLabelForByText = ( string ) ->
    $('#platforms-list label').filter( ->
        $.trim(this.firstChild.nodeValue) == $.trim(string);
    ).attr('for')

selectPlatforms = ( platforms ) ->
    $('#platforms-list .check_boxes').prop('checked', '')

    for platform in platforms.split( /,/ )
        $('#' + findLabelForByText(platform)).prop('checked', 'checked')

setup = () ->
    $('.profile-form input#profile-checks-search').keyup ->
        searchChecks $(this).val()

    $('.profile-form button.check').click ->
        $('.profile-checks input:visible:checkbox').prop('checked','checked')
        false

    $('.profile-form button.uncheck').click ->
        $('.profile-checks input:visible:checkbox').prop('checked', '')
        false

    $('.profile-form button.platforms-preset').click ->
        selectPlatforms $(this).html()
        false

$(document).on 'page:load', setup
jQuery setup
