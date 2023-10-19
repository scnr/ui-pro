# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

setup = () ->
    $('#site_protocol').change ->
        $('#site_port').val( `$('#site_protocol').val() == 'http' ? 80 : 443` )

jQuery setup
$(document).on( "turbo:load", setup )
