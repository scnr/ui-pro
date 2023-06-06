export default function gaugeChartTextPlugin(options = {}) {
  return {
    id: 'gaugeChartText',
    afterDatasetsDraw(chart, args, pluginOptions) {
      const { ctx, data, chartArea: { top, bottom, left, right, width, height }, scales: { r } } = chart;

      ctx.save();
      const xCoor = chart.getDatasetMeta(0).data[0].x;
      const yCoor = chart.getDatasetMeta(0).data[0].y;
      const label = options.label || data.datasets[0].data[0];
      const unit = options.unit;
      const showLabel = options.show_label === undefined ? true : options.show_label;

      function textLablel(text, x, y, fontSize, fillStyle, textBaseLine, textAlign) {
        if (text === undefined) {
          return;
        };

        ctx.font = `${fontSize}px sans-serif`;
        ctx.fillStyle = fillStyle;
        ctx.textBaseLine = textBaseLine;
        ctx.textAlign = textAlign;
        ctx.fillText(text, x, y);
      };

      textLablel(options.min || 0, left, yCoor + 20, 12, '#666', 'top', 'left');
      textLablel(options.max || options.value, right, yCoor + 20, 12, '#666', 'top', 'right');

      if (showLabel) {
        textLablel(label, xCoor, yCoor, 36, 'black', 'bottom', 'center');
        textLablel(unit, xCoor, yCoor + 20, 16, 'black', 'bottom', 'center');
      } else {
        textLablel(unit, xCoor, yCoor, 16, 'black', 'bottom', 'center');
      };
    }
  };
};
