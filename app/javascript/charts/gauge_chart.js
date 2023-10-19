import Chart from 'chart.js/auto';
import gaugeChartTextPlugin from './plugins/gauge_chart_text_plugin';

export default class GaugeChart {
  constructor(chartElementId, options = {}) {
    this.chartElementId = chartElementId;
    this.options = options;

    this.chartInstance = null;
    this.thresholdColors = ['#FF0000', '#F97600', '#F6C600', '#60B044'];
    this.thresholdStep = (options.max || 0) / 4;
    this.greyColor = 'rgba(224, 224, 224, 1)';
  }

  initializeChart() {
    const chartElement = document.getElementById(this.chartElementId);

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
          data: this.initialDataset(),
          backgroundColor: [this.getGaugeColor(this.options.value), this.greyColor],
          borderWidth: 1,
          cutout: '60%',
          circumference: 180,
          rotation: 270
        }]
      },
      options: {
        pluginData: {
          value: this.options.value || 0,
          max: this.options.max || this.options.value || 0,
          label: this.options.label,
        },
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

  getGaugeColor(value) {
    if (value <= this.thresholdStep) {
      return this.getThresholdColors()[0];
    } else if ((value > this.thresholdStep) && (value <= this.thresholdStep * 2)) {
      return this.getThresholdColors()[1];
    } else if ((value > this.thresholdStep * 2) && (value <= this.thresholdStep * 3)) {
      return this.getThresholdColors()[2];
    } else {
      return this.getThresholdColors()[3]
    };
  }

  initialDataset() {
    const currentValue = this.options.value || 0;
    const maxValue = this.options.max || this.options.value || 0;

    return [currentValue, this.getValueDifference(currentValue, maxValue)];
  }

  getValueDifference(currentValue, maxValue) {
    if (currentValue >= maxValue) {
      return 0;
    };

    return maxValue - currentValue;
  };

  getThresholdColors() {
    if (this.options.better === 'low') {
      this.thresholdColors.reverse();
    };

    return this.thresholdColors;
  }

  updateDataset(data) {
    if (!this.chartInstance) {
      return;
    };

    const { value, label, max } = data;

    this.chartInstance.options.pluginData.value = value;
    this.chartInstance.options.pluginData.max = max || this.options.max || value;
    this.chartInstance.options.pluginData.label = label || this.options.label;
    this.thresholdStep = this.chartInstance.options.pluginData.max / 4;

    this.chartInstance.data.datasets[0].data = [value, this.getValueDifference(value, this.chartInstance.options.pluginData.max)];
    this.chartInstance.data.datasets[0].backgroundColor = [this.getGaugeColor(value), this.greyColor];
    this.chartInstance.update();
  };
}
