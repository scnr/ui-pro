initializeRefreshablePartials = ->
    $('[data-refreshable-partial]').each ( i, e ) ->
        e   = $(e)
        url = e.data('refreshable-partial')

        $.get url, (data) ->
            if url.endsWith( '.js' )
                eval( data );
            else
                e.html( data )

setup = ->
    if !window.refreshablePartials
        window.refreshablePartials = setInterval( initializeRefreshablePartials, 5000 )

$(document).ready( setup )
$(document).on( "turbo:load", setup );
