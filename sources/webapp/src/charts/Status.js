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
    }
  },
  methods: {
    renderLinesChart: function() {
      this.renderChart({
        labels: this.xaxisLabels,
        datasets: this.datasets
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
