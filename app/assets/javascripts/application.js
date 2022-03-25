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
//= require bootstrap
//= require d3
//= require c3
//= require ace/ace
//= require ace/worker-html
//= require ace/theme-monokai
//= require ace/mode-ruby
//= require scan_results/live.js
//= require_tree .

function loading(){
    $('#loading').show();
}

function loaded(){
    $('#loading').hide();
}

jQuery.fn.reverse = [].reverse;
jQuery.fn.exists = function(){ return this.length > 0; };

$.expr[':'].icontains = function(obj, index, meta, stack){
    return (obj.textContent || obj.innerText || jQuery(obj).text() || '').
        toLowerCase().indexOf(meta[3].toLowerCase()) >= 0;
};

String.prototype.endsWith = function(suffix) {
    return this.indexOf(suffix, this.length - suffix.length) !== -1;
};

String.prototype.toHHMMSS = function () {
    var sec_num = parseInt(this, 10);
    var hours   = Math.floor(sec_num / 3600);
    var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
    var seconds = sec_num - (hours * 3600) - (minutes * 60);

    if (hours   < 10) {hours   = "0"+hours;}
    if (minutes < 10) {minutes = "0"+minutes;}
    if (seconds < 10) {seconds = "0"+seconds;}
    var time    = hours+':'+minutes+':'+seconds;
    return time;
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

function goTo( location ){
    // Restore the last open tab from the URL fragment.
    if( !location || location.length <= 0 ) return;

    var target = $('#' + location.replace( /\//g, '-' ));

    var nodes = target.parents();
    nodes.reverse();
    nodes.push( target );

    nodes.each(function() {
        var level = $(this);

        var id = level.attr('id');

        if( !id ) return;

        // Mark all other tabs of this level as inactive...
        level.siblings().removeClass('active');
        //.. and activate the one we want.
        level.addClass('active');
        // In case it's hidden.
        level.show();

        var tab_selector;
        if( !(tab_selector = $('a[href="#!/' + id + '"]')).exists() ) {
            if( !(tab_selector = $('a[href="#!/' + id.replace( /-/g, '/' ) + '"]')).exists() ) {
                return;
            }
        }

        // Mark all links in the navigation tree as active at every step.
        tab_selector.parents('li').siblings().removeClass('active');
        tab_selector.parents('li').addClass('active');


        // In case it's a collapsible.
        if( level.hasClass('collapse') ) {
            level.addClass('in');
        }

        target = level;
    });

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

var updatePage = (function () {
    var scrollPosition;

    function reload () {
        if(
            window.location.pathname.endsWith( '/live' ) ||
            $( 'input' ).is(':visible')
        ) { return }

        scrollPosition = [window.scrollX, window.scrollY];
        Turbo.visit( window.location.toString(), { action: 'replace' } );
    }

    $(document).on( 'turbo:load', function () {
        if( scrollPosition ) {
            setTimeout( () => {
                window.scrollTo.apply( window, scrollPosition );
                scrollPosition = null;
            });
        }
    });

    return reload
})()

function setupPageUpdate() {
    if( !window.updatePageInterval )
        window.updatePageInterval = window.setInterval( updatePage, 2500 )
}


function setup() {
    // Init all tooltips.
    $('[data-toggle="tooltip"]').tooltip();

    $('a[data-toggle="tab"]').on('shown.bs.tab', setupScroll);

    setupScroll();
    setupPageUpdate();
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

$(document).ajaxStop( function() {
    setup();
});

$(document).ready( function( $ ) {
    setup();
});

$(document).on( "turbo:load", setup );
