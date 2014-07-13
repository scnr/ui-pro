updateRefreshable = ( e ) ->
    $.get e.data('refreshable'), ( html ) ->
        e.html( html )

initializeRefreshables = ->
    $('[data-refreshable]').each ( i, e ) ->
        e = $(e);

        updateRefreshable(e) if( e.html().length == 0 )

        dispatcher.bind 'refreshable://' + e.data('refreshable'), ->
            updateRefreshable(e);

pageReady = ->
    initializeRefreshables()

$(document).ready( pageReady )
$(document).on( 'page:load', pageReady )
