// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap
//= require d3
//= require c3
//= require websocket_rails/main
//= require_tree .

$.expr[':'].icontains = function(obj, index, meta, stack){
    return (obj.textContent || obj.innerText || jQuery(obj).text() || '').
        toLowerCase().indexOf(meta[3].toLowerCase()) >= 0;
};

String.prototype.endsWith = function(suffix) {
    return this.indexOf(suffix, this.length - suffix.length) !== -1;
};

function loading(){
    $('#loading').show();
}

function loaded(){
    $('#loading').hide();
}

function setupScroll(){
    if( $('#sidebar-container').is(':visible' ) ) {
        $('body').scrollspy({ target: '#sidebar-container', offset: 50 });
        $('body').scrollspy('refresh');
    } else {
        $('body').removeData( 'bs.scrollspy' );
    }

    $( '.scroll' ).click( function( event ) {
        event.preventDefault();
        $( 'html,body' ).animate( { scrollTop: $( this.hash ).offset().top -
            $( 'header' ).height() - 45 }, 500 );
    });
}

function setup() {
    $('a[data-toggle="tab"]').on('shown.bs.tab', setupScroll);
    setupScroll();
}

$(document).ready( function( $ ) {
    setup();
});

$(document).on( 'page:fetch', function( $ ) {
    loading();
});

$(document).on( 'page:load', function( $ ) {
    setup();
});

$(document).ajaxStop( function() {
    loaded();
});

$(window).bind( "page:restore", function () {
    loaded();
    setup();
});
