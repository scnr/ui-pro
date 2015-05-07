setup = ->
    scrollToChild( '.highlight-container', '.highlight' )

jQuery ->
    setup()
$(document).on 'page:fetch', ->
    setup()
$(document).on 'page:load', ->
    setup()
$(document).on 'page:restore', ->
    setup()
