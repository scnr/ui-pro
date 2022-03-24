# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

setup = () ->
    if $('.coverage-bar').exists()
        $('.coverage-bar').click ->
            window.location = '#!/coverage/' + $(this).data('location')

jQuery setup
$(document).on( "turbo:load", setup )
