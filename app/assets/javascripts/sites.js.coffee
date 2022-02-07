# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

addHighlight = (selector) ->
    $(selector).addClass('label-info');

removeHighlight = (selector) ->
    $(selector).removeClass('label-info');

window.generateIssuesChart = () ->
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

window.updateGauges = ( snapshot ) ->
    window.http_max_concurrency_gauge.load(
        columns: [['Request concurrency', snapshot.http_max_concurrency]]
    )

    window.http_average_responses_per_second_gauge.load(
        columns: [['Average responses per second', snapshot.http_average_responses_per_second]]
    )

    window.http_average_response_time_gauge.load(
        columns: [['Average response times', snapshot.http_average_response_time]]
    )

    window.http_time_out_count_gauge.load(
        columns: [['Timed out requests', snapshot.http_time_out_count]]
    )

    window.http_request_count_gauge.load(
        columns: [['Requests', snapshot.http_time_out_count]]
    )

window.generateGaugeChart = ( bindto, options ) ->
    threshold_step = options.max / 4

    threshold_colors = ['#FF0000', '#F97600', '#F6C600', '#60B044']
    if options.better == 'low'
        threshold_colors = threshold_colors.reverse()

    c3.generate
        bindto: bindto,
        size:
            height: 180
        data:
            type: 'gauge'
            columns: [[options.name, options.value]]
        gauge:
            label:
                format: (value, ratio) ->
                    options.label || value
                show: options.show_labels == undefined ? true : options.show_labels
            min: options.min || 0,
            max: options.max,
            units: options.unit
        color:
            pattern: threshold_colors,
            threshold:
                values: [
                    threshold_step,
                    threshold_step * 2,
                    threshold_step * 3,
                    threshold_step * 4
                ]

window.clearChartPoints = () ->
    $('.c3-circle').css( 'visibility', 'hidden' )

window.highlightChartPoints = ( point ) ->
    window.clearChartPoints()
    $('.c3-circle-' + point.index).css( 'visibility', 'visible' )

window.generateLineChart = ( bindto, options ) ->
    threshold_step = options.max / 4

    threshold_classes = [
        'chart-region-poor', 'chart-region-fair', 'chart-region-good',
        'chart-region-excellent'
    ]

    if options.better == 'low'
        threshold_classes = threshold_classes.reverse()

    c3.generate
        bindto: bindto,
        size:
            height: 180
        data:
            type: 'line'
            x: 'x',
            columns: [
                ['x'].concat( options.x_axis ),
                [options.name].concat( options.values )
            ],
            onmouseover: ( point, i ) ->
                window.highlightChartPoints( point )
            onmouseout: window.clearChartPoints
        legend:
            show: false
        axis:
            x:
                show: false
            y:
                min: options.min || 0,
                padding:
                    bottom: 0
        tooltip:
            contents: ( point ) ->
                snapshot = window.performance_snapshots[point[0].index]

                '
                <div class="panel panel-default" style="opacity: 0.7">
                    <div class="panel-body">
                        <table class="table table-condensed table-borderless">
                            <tbody>
                            <tr>
                                <th>Duration</th>
                                <td>' + snapshot.duration + '</td>
                            </tr>
                            <tr>
                                <th>Requests</th>
                                <td>' + snapshot.http_request_count + '</td>
                            </tr>
                            <tr>
                                <th>Request concurrency</th>
                                <td>' + snapshot.http_max_concurrency + '</td>
                            </tr>
                            <tr>
                                <th>Average responses per second</th>
                                <td>' + snapshot.http_average_responses_per_second + '</td>
                            </tr>
                            <tr>
                                <th>Average response times</th>
                                <td>' + snapshot.http_average_response_time + ' seconds</td>
                            </tr>
                            <tr>
                                <th>Timed out requests</th>
                                <td>' + snapshot.http_time_out_count + '</td>
                            </tr>
                            </tbody>
                         </table>
                     </div>
                 </div>'
        regions: [
            {
                axis: 'y',
                end:   threshold_step,
                class: threshold_classes[0]
            },
            {
                axis: 'y',
                start: threshold_step,
                end:   threshold_step * 2,
                class: threshold_classes[1]
            },
            {
                axis: 'y',
                start: threshold_step * 2,
                end:   threshold_step * 3,
                class: threshold_classes[2]
            },
            {
                axis: 'y',
                start: threshold_step * 3,
                class: threshold_classes[3]
            }
        ]


setup = () ->
    $('#site_protocol').change ->
        $('#site_port').val( `$('#site_protocol').val() == 'http' ? 80 : 443` )

jQuery setup

