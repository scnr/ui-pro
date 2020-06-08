window.ticks = 0

window.start_live_stream_clock = ( duration ) ->
    set_live_stream_clock( duration )
    setInterval( tick_live_stream_clock, 1000, duration )

tick_live_stream_clock = ( duration ) ->
    window.ticks += 1
    set_live_stream_clock( (parseInt( duration, 10 ) + window.ticks).toString() )

set_live_stream_clock = ( duration ) ->
    $('#live-stream-clock').html( duration.toHHMMSS() )

acknowledge = (e) ->
    $(e).removeClass( 'pulsating' )

update_feed = ( acknowledge_all ) ->
    return if !window.location.pathname.endsWith( '/live' )

    d   = new Date()
    now = d.getTime()

    $.get window.location.pathname + '.js', {
        from: window.live_stream_from,
        to:   now
    },
    (data) ->
        if acknowledge_all
            acknowledge( '.live-stream-batch' )

        $('.live-stream-batch').mouseover ->
            acknowledge( this )

    window.live_stream_from = now

merge_feed = () ->
    window.live_stream_from = null
    clear_feed()
    update_feed( true )
    acknowledge( '.live-stream-batch' )

clear_feed = () ->
    $('#live-stream').html('')

setup_feed = () ->
    if window.liveIntervalID
        clearInterval( window.liveIntervalID )
        window.liveIntervalID = null

    update_feed( true )
    window.liveIntervalID = window.setInterval( update_feed, 1000 )

setup = () ->
    if $('#live-stream').is(':visible')
        setup_feed()
    $('#acknowledge-all').click ->
        acknowledge( '.live-stream-batch' )
    $('#merge-updates').click ->
        merge_feed()
    $('#clear-updates').click ->
        clear_feed()

$(document).on 'turbolinks:load', setup
jQuery setup
