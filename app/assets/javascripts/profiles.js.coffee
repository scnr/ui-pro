# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

searchChecks = ( val ) ->
    $(".profile-checks").show()

    val = val.replace( /\(|\)/m, '' )

    if( val != '' )
        for token in val.split( /\s+/ )
            $(".profile-checks:not(:icontains(" + token + "))").hide()
    else
        $(".profile-checks").show()

setup = () ->
    $('.profile-form input#profile-checks-search').keyup ->
        searchChecks $(this).val()

    $('.profile-form button.check').click ->
        $('.profile-checks input:visible:checkbox').prop('checked','checked')
        false

    $('.profile-form button.uncheck').click ->
        $('.profile-checks input:visible:checkbox').prop('checked', '')
        false


jQuery setup
