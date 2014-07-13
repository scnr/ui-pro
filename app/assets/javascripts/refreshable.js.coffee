initializeRefreshables = ->
    $('[data-refreshable]').each ( i, e ) ->
        e   = $(e)
        url = e.data('refreshable')

        dispatcher.bind 'refreshable://' + e.data('refreshable'), (data) ->
#            console.log data
            if url.endsWith( '.js' )
                eval( data );
            else
                e.html( data )

pageReady = ->
    initializeRefreshables()

$(document).ready( pageReady )
$(document).on( 'page:load', pageReady )
