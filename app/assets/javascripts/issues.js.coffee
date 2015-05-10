setup = ->
    scrollToChild( '.highlight-container', '.highlight' )
    $('select#issue_state').on 'change', ->
        $('.edit_issue').submit()

jQuery ->
    setup()
$(document).on 'page:fetch', ->
    setup()
$(document).on 'page:load', ->
    setup()
$(document).on 'page:restore', ->
    setup()
