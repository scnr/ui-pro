window.generateIssuesChart = function() {
  const ctx = document.getElementById('chart-issues').getContext('2d');
  const chart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: [],
      datasets: [
        {
          label: 'Issues',
          data: [],
          backgroundColor: '#1f77b4'
        },
        {
          label: 'Severity',
          data: [],
          type: 'line',
          yAxisID: 'y2',
          borderColor: '#ff7f0e',
          fill: false
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      legend: {
        display: false
      },
      scales: {
          x: {
            type: 'category',
            ticks: {
              autoSkip: false,
              maxRotation: 15,
              minRotation: 15
            }
          },
          y: {
            position: 'outer',
            title: {
              display: true,
              text: ''
            }
          },
          y2: {
            position: 'outer',
            type: 'category',
            title: {
              display: true,
              text: ''
            },
            ticks: {
              callback: function(value, index, values) {
                return ["Informational", "Low", "Medium", "High"][value - 1];
              }
            },
            labels: {
              show: true
            }
          }
      },
      plugins: {
        legend: {
            display: false
        }
      }
    }
  });

  return chart;
};
