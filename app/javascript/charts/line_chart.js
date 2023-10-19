import Chart from 'chart.js/auto';

export default class LineChart {
  constructor(chartElementId, options = {}) {
    this.chartElementId = chartElementId;
    this.options = options;

    this.chartInstance = null;
  }

  initializeChart() {
    const chartElement = this.getChartElement();

    if (!chartElement) {
      return;
    };

    const ctx = chartElement.getContext('2d');
    const chartInstance = Chart.getChart(ctx);

    if (chartInstance) {
      this.chartInstance = chartInstance;
      return;
    };

    this.chartInstance = this.createChart(ctx);
  }

  createChart(ctx) {
    return new Chart(ctx, {
      type: 'line',
      data: {
        labels: this.options.x_axis,
        datasets: [{
          label: this.options.name || [],
          data: this.options.values || []
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        interaction: {
          mode: 'index',
          intersect: false,
        },
        scales: {
          x: {
            display: false
          },
          y: {
            min: this.options.min || 0,
            padding: {
              bottom: 0
            }
          }
        },
        plugins: {
          legend: {
            display: false
          },
          title: {
            display: false
          },
          tooltip: {
            enabled: false,
            position: 'average',
            external: this.externalTooltipHandler
          }
        }
      }
    });
  }

  getChartElement() {
    return document.getElementById(this.chartElementId);
  }

  externalTooltipHandler(context) {
    const { chart, tooltip } = context;

    let tooltipEl = chart.canvas.parentNode.querySelector('.performance-snapshot-tooltip');

    if (!tooltipEl) {
      tooltipEl = document.createElement('div');
      tooltipEl.classList.add('panel', 'panel-default', 'performance-snapshot-tooltip');
      tooltipEl.style.opacity = 0;

      chart.canvas.parentNode.appendChild(tooltipEl);
    };

    if (tooltip.opacity === 0) {
      tooltipEl.style.opacity = 0;
      return;
    };

    const index = tooltip.dataPoints[0].dataIndex;
    const snapshot = window.performance_snapshots[index];

    const htmlContent = `
      <div class="panel-body">
        <table class="table table-condensed table-borderless">
          <tbody>
            <tr>
              <th>Duration</th>
              <td>${snapshot.duration}</td>
            </tr>
            <tr>
              <th>WebApp responsiveness</th>
              <td>${snapshot.total_average_app_time.toFixed(2)} seconds/response</td>
            </tr>
            <tr>
              <th>Failed HTTP requests</th>
              <td>${snapshot.http_failed_count}</td>
            </tr>
            <tr>
              <th>Responses/second</th>
              <td>${snapshot.http_average_responses_per_second}</td>
            </tr>
            <tr>
              <th>Server responsiveness</th>
              <td>${snapshot.http_average_response_time} seconds/response</td>
            </tr>
            <tr>
              <th>Bandwidth (d/l)</th>
              <td>${snapshot.download_kbps}/${snapshot.upload_kbps} KBps</td>
            </tr>
            <tr>
              <th>Client reliability</th>
              <td>${snapshot.browser_job_failed_count} failed browser jobs</td>
            </tr>
            <tr>
              <th>Performance</th>
              <td>${snapshot.http_max_concurrency} connections</td>
            </tr>
            <tr>
              <th>HTTP Requests</th>
              <td>${snapshot.http_request_count}</td>
            </tr>
            <tr>
              <th>Browser jobs</th>
              <td>${snapshot.browser_job_count}</td>
            </tr>
          </tbody>
        </table>
      </div>
    `;

    tooltipEl.innerHTML = htmlContent;

    const { offsetLeft: positionX, offsetTop: positionY } = chart.canvas;
    const tooltipWidth = tooltipEl.offsetWidth;
    const tooltipHeight = tooltipEl.offsetHeight;
    const mouseX = tooltip.x;
    const mouseY = tooltip.y;

    let left = positionX + mouseX;
    let top = positionY + mouseY;

    // Adjust left position if tooltip overflows on the right side
    if (left + tooltipWidth > window.innerWidth) {
      left = window.innerWidth - tooltipWidth;
    };

    // Adjust top position if tooltip overflows at the bottom
    if (top + tooltipHeight > window.innerHeight) {
      top = window.innerHeight - tooltipHeight;
    };

    tooltipEl.style.opacity = 0.7;
    tooltipEl.style.left = Math.max(left, 0) + 'px';
    tooltipEl.style.top = Math.max(top, 0) + 'px';
  }

  updateDataset(data) {
    if (!this.chartInstance) {
      return;
    };

    const { labels, values } = data;

    this.chartInstance.data.labels = labels;
    this.chartInstance.data.datasets[0].data = values;
    this.chartInstance.update();
  }
}
