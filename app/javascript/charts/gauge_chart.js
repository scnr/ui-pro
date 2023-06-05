import Chart from 'chart.js/auto';
import gaugeChartTextPlugin from './plugins/gauge_chart_text_plugin';

export default class GaugeChart {
  constructor(chartElementId, options = {}) {
    this.chartElementId = chartElementId;
    this.options = options;

    this.chartInstance = null;
    this.thresholdColors = ['#FF0000', '#F97600', '#F6C600', '#60B044'];
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
      type: 'doughnut',
      data: {
        labels: [this.options.name, ''],
        datasets: [{
          data: [this.options.value, this.options.max - this.options.value],
          backgroundColor: [
            this.getGradientSegment(ctx),
            'rgba(224, 224, 224, 1)'
          ],
          borderWidth: 1,
          cutout: '60%',
          circumference: 180,
          rotation: 270
        }]
      },
      options: {
        aspectRatio: 1.5,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            filter: function(tooltipItem) {
              return tooltipItem.label !== '';
            }
          }
        },
      },
      plugins: [gaugeChartTextPlugin(this.options)]
    });
  }

  getGradientSegment(ctx) {
    const chartElement = this.getChartElement();

    if (!chartElement) {
      return;
    };

    const chartWidth = chartElement.getBoundingClientRect().width;
    const gradientSegment = ctx.createLinearGradient(0, 0, chartWidth, 0);

    this.getThresholdColors().forEach((color, index) => {
      gradientSegment.addColorStop(0.25 * index, color);
    });

    return gradientSegment;
  }

  getThresholdColors() {
    if (this.options.better === 'low') {
      this.thresholdColors.reverse();
    };

    return this.thresholdColors;
  }

  getChartElement() {
    return document.getElementById(this.chartElementId);
  }

  updateDataset(data) {
    // TODO: needs to be implemented.
  }
}
