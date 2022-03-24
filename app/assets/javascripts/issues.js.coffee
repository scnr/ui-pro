setup = ->
    scrollToChild( '.highlight-container', '.highlight' )
    $('select#issue_state').on 'change', ->
        $('.edit_issue').submit()

jQuery ->
    setup()

$(document).on( "turbo:load", setup );
