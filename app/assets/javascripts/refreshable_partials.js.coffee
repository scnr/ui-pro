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

setup = ->
    initializeRefreshablePartials()

$(document).ready( setup )
$(document).on( "turbo:load", setup );
