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
//= require ace/ace
//= require ace/worker-html
//= require ace/theme-monokai
//= require ace/mode-ruby
//= require_tree .

jQuery.fn.exists = function(){ return this.length > 0; };

$.expr[':'].icontains = function(obj, index, meta, stack){
    return (obj.textContent || obj.innerText || jQuery(obj).text() || '').
        toLowerCase().indexOf(meta[3].toLowerCase()) >= 0;
};

String.prototype.endsWith = function(suffix) {
    return this.indexOf(suffix, this.length - suffix.length) !== -1;
};

window.topOffset = undefined;

function ace_editor( id ) {
    var editor = ace.edit( id );
    editor.setTheme( 'ace/theme/monokai' );
    editor.getSession().setMode( 'ace/mode/ruby' );
    editor.setShowPrintMargin(false);
    editor.getSession().setUseSoftTabs( true );
    editor.getSession().setUseWrapMode( true );
    return editor;
}

function loading(){
    $('#loading').show();
}

function loaded(){
    $('#loading').hide();
}

function goTo( location ){
    // Restore the last open tab from the URL fragment.
    if( !location || location.length <= 0 ) return;

    // Clear the current active status of the navigation links.
    $("nav li").removeClass("active");

    var splits          = location.split('/');
    var href_breadcrumb = '#!/';
    var id_breadcrumb   = '';

    for( var i = 0; i < splits.length; i++ ) {
        href_breadcrumb += splits[i];
        id_breadcrumb   += splits[i];

        var tab_selector = $('a[href="' + href_breadcrumb + '"]');
        var level        = $('#' + id_breadcrumb );

        getRemote( level );

        // Mark all links in the navigation tree as active at every step.
        tab_selector.parents('li').siblings().removeClass('active');
        tab_selector.parents('li').addClass('active');

        // Mark all other tabs of this level as inactive...
        level.siblings().removeClass('active');
        //.. and activate the one we want.
        level.addClass('active');

        // In case it's hidden.
        level.show();

        // In case it's a collapsible.
        if( level.hasClass('collapse') ) {
            level.addClass('in');
        }

        if( i != splits.length - 1) {
            href_breadcrumb += '/';
            id_breadcrumb   += '-';
        }
    }

    getRemote( $('a[href="' + href_breadcrumb + '"]') );

    var target = $('#' + id_breadcrumb);
    if( !target.length ) return;
    if( !target.hasClass('tab-pane') ) {
        $('html,body').scrollTop( target.offset().top - window.topOffset );
    }
}

function goToLocation( location ){
    window.location.hash = '#!/' + location;
}

function openFromWindowLocation(){
    goTo( window.location.hash.split('#!/')[1] );
}

function idFromWindowLocation() {
    var loc = window.location.hash.split( '#!/' )[1];
    if( !loc ) return;

    return loc.replace( /\//g, '-' )
}

function scrollToActiveElementFromWindowLocation() {
    var element = $('#' + idFromWindowLocation());
    if( !element.length ) return;

    $('html,body').scrollTop( element.offset().top - window.topOffset );
}

// Parent must have 'position: relative;'
function scrollToChild( parent_selector, child_selector ){
    var parent = $(parent_selector);

    if( !parent.exists() ) return;

    parent.each( function(){
        var current_parent = $(this);

        var child = current_parent.children( child_selector );

        if( !child.exists() ) return;

        current_parent.scrollTop(
            current_parent.scrollTop() + child.position().top -
            (current_parent.height() / 2) + (child.height())
        );
    });

}

function getRemote( element ) {
    if( !element.attr('data-js') ) return;

    $.ajax( element.attr('data-js') + '.js', {
        async:    false,
        complete: function ( data ){
            eval( data );
        }
    })
}

function setupScroll(){
    if( $('#scrollspy-container').is(':visible' ) ) {
        $('body').scrollspy({ target: '#scrollspy-container', offset: window.topOffset + 10 });
        $('body').scrollspy('refresh');
    } else {
        $('body').removeData( 'bs.scrollspy' );
    }

    $( '.scroll' ).click( function( event ) {
        event.preventDefault();
        $( 'html,body' ).animate( { scrollTop: $( this.hash ).offset().top -
            window.topOffset }, 500 );
    });
}

function setup() {
    // Init all tooltips.
    $('[data-toggle="tooltip"]').tooltip();

    $('a[data-toggle="tab"]').on('shown.bs.tab', setupScroll);

    setupScroll();
}

jQuery(function ($) {
    window.topOffset = $('#top-nav').height();

    // Restore the last open tab from the URL fragment.
    openFromWindowLocation();
    scrollToActiveElementFromWindowLocation();
});

$(window).bind( 'hashchange', function () {
    openFromWindowLocation();
});

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
    setup();
});

$(window).bind( "page:restore", function () {
    loaded();
    setup();
});
