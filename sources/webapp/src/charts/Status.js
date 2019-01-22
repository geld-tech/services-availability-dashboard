import {Line} from 'vue-chartjs'

export default {
  extends: Line,
  props: ['metrics', 'services', 'datasets'],
  mounted () {
    this.renderLinesChart()
  },
  computed: {
    linesChartData: function() {
      return this.metrics
    },
    xaxisLabels: function() {
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
    },
    charts: function() {
      var charts = []
      for (var i = 0; i < this.datasets.length; ++i) {
        var chart = {}
        chart.label = this.datasets[i].label
        chart.fill = false
        chart.backgroundColor = this.datasets[i].colors
        chart.borderColor = this.datasets[i].colors
        chart.data = this.datasets[i].data
        charts.push(chart)
      }
      return charts
    }
  },
  methods: {
    renderLinesChart: function() {
      this.renderChart({
        labels: this.xaxisLabels,
        datasets: this.charts
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
