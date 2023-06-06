import Chart from 'chart.js/auto';
import gaugeChartTextPlugin from './plugins/gauge_chart_text_plugin';

export default class GaugeChart {
  constructor(chartElementId, options = {}) {
    this.chartElementId = chartElementId;
    this.options = options;

    this.chartInstance = null;
    this.thresholdColors = ['#FF0000', '#F97600', '#F6C600', '#60B044'];
    this.thresholdStep = options.max / 4;
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
          data: [this.getCurrentValue(), this.options.max - this.getCurrentValue()],
          backgroundColor: [
            this.getGaugeColor(),
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

  getGaugeColor() {
    const currentValue = this.getCurrentValue();

    if (currentValue <= this.thresholdStep) {
      return this.getThresholdColors()[0];
    } else if ((currentValue > this.thresholdStep) && (currentValue <= this.thresholdStep * 2)) {
      return this.getThresholdColors()[1];
    } else if ((currentValue > this.thresholdStep * 2) && (currentValue <= this.thresholdStep * 3)) {
      return this.getThresholdColors()[2];
    } else {
      return this.getThresholdColors()[3]
    };
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

  getCurrentValue() {
    return this.options.value;
  }

  updateDataset(data) {
    // TODO: needs to be implemented.
  }
}
