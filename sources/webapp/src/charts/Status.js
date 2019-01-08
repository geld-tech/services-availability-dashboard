import {Line} from 'vue-chartjs'

var chartColors = {
  red: 'rgb(255, 99, 132)',
  orange: 'rgb(255, 159, 64)',
  yellow: 'rgb(255, 205, 86)',
  green: 'rgb(75, 192, 192)',
  blue: 'rgb(54, 162, 235)',
  purple: 'rgb(153, 102, 255)',
  grey: 'rgb(231,233,237)'
}

export default {
  extends: Line,
  props: ['metrics', 'services'],
  mounted () {
    this.renderLinesChart()
  },
  computed: {
    linesChartData: function() {
      return this.metrics
    },
    datetimeLabels: function() {
      var labels = []
      for (var i = 0; i < this.metrics.length; ++i) {
        labels.push(this.metrics[i].date_time)
      }
      return labels
    },
    latencies: function() {
      var latencies = []
      for (var i = 0; i < this.metrics.length; ++i) {
        latencies.push(this.metrics[i].latency)
      }
      return latencies
    }
  },
  methods: {
    renderLinesChart: function() {
      this.renderChart({
        labels: this.datetimeLabels,
        datasets: [
          {
            label: 'Service',
            fill: false,
            backgroundColor: chartColors.blue,
            borderColor: chartColors.blue,
            data: this.latencies
          }
        ]
      },
      {
        maintainAspectRatio: false,
        responsive: true,
        animation: false,
        elements: {
          point: {
            radius: 0
          }
        },
        scales: {
          xAxes: [{
            ticks: {
              autoSkip: true,
              maxTicksLimit: 12
            },
            scaleLabel: {
              display: false
            }
          }],
          yAxes: [{
            stacked: false,
            ticks: {
              beginAtZero: true,
              stepSize: 1
            },
            scaleLabel: {
              display: true,
              labelString: 'Latency (ms)'
            }
          }]
        }
      })
    }
  },
  watch: {
    metrics: function() {
      this.$data._chart.destroy()
      this.renderLinesChart()
    }
  }
}
