initializeRefreshablePartials = ->
    $('[data-refreshable-partial]').each ( i, e ) ->
        e   = $(e)
        url = e.data('refreshable-partial')

        dispatcher.bind 'refreshable-partial://' + e.data('refreshable-partial'), (data) ->
#            console.log data
            if url.endsWith( '.js' )
                eval( data );
            else
                e.html( data )

pageReady = ->
    initializeRefreshablePartials()

$(document).ready( pageReady )
$(document).on( 'page:load', pageReady )
