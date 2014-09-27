# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

addHighlight = (selector) ->
    $(selector).addClass('label-info');

removeHighlight = (selector) ->
    $(selector).removeClass('label-info');

generateIssuesChart = () ->
    c3.generate
        bindto: '#chart-issues',
        size:
            height: 250
        data:
            x: 'x'
            columns: []
            axes:
                Severity: 'y2'
            type: 'bar',
            types:
                Severity: 'line'
            regions: [],
        axis:
            x:
                type: 'category',
                tick:
                    rotate: 15
            y:
                label:
                    position: 'outer-center'
            y2:
                label:
                    position: 'outer-center'
                show: true,
                type: 'category',
                categories: [1,2,3,4]
                tick:
                    format: (d) ->
                        ["Informational","Low","Medium","High"][d - 1]
        padding:
            bottom: 40
        color:
            pattern: [ '#1f77b4', '#ff7f0e' ]

jQuery ->
    $('#highlight-forms').mouseover ->
        addHighlight('.issue-summary-vector-form')
    $('#highlight-forms').mouseout ->
        removeHighlight('.issue-summary-vector-form')
    window.issuesChart = generateIssuesChart()
