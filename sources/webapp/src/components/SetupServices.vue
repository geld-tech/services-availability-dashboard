<template>
    <div>
        <h2>Services Availability</h2>
        <div v-if="servicesSet" class="pt-1">
            <p>Services Availability monitor successfully configured!</p>
        </div>
        <div v-else>
            <p>Enter the name, URL and port of the service(s) to monitor the availability for:</p>
            <b-form @submit="onSubmitServices" @reset="onResetServices" id="servicesForm" v-if="show">
                <b-container fluid>
                  <b-row class="my-1" no-gutters>
                    <b-col sm="5"><label>Service Name</label></b-col>
                    <b-col sm="4"><label>URL</label></b-col>
                    <b-col sm="2"><label>Port</label></b-col>
                    <b-col sm="1"></b-col>
                  </b-row>
                  <b-row class="my-1" no-gutters v-for="(service, index) in services" v-bind:key="index">
                    <b-col sm="5">{{ service.name }}</b-col>
                    <b-col sm="4">{{ service.url }}</b-col>
                    <b-col sm="2">{{ service.port }}</b-col>
                    <b-col sm="1"><b-button @click="deleteRow(index)"><strong> - </strong></b-button></b-col>
                  </b-row>
                  <b-row class="my-1" no-gutters>
                    <b-col sm="5"><b-form-input type="text" v-model="form.serviceName" id="serviceName"></b-form-input></b-col>
                    <b-col sm="4"><b-form-input type="text" v-model="form.serviceUrl" id="serviceUrl"></b-form-input></b-col>
                    <b-col sm="2"><b-form-input type="text" v-model="form.servicePort" id="servicePort"></b-form-input></b-col>
                    <b-col sm="1"><b-button @click="addRow" id="addRowButton"><strong> + </strong></b-button></b-col>
                  </b-row>
                  <b-row class="my-1" no-gutters>
                    <b-col sm="10">
                      <b-button type="reset" variant="danger" v-bind:disabled="disableServicesButtons" id="servicesClearButton">Clear</b-button>
                      <b-button type="submit" variant="primary" v-bind:disabled="disableServicesButtons" id="servicesSubmitButton">Submit</b-button>
                    </b-col>
                  </b-row>
                </b-container>
            </b-form>
        </div>
    </div>
</template>

<script>
import { getConfig, storeServices } from '@/api'

export default {
  name: 'SetupServices',
  props: ['servicesSet'],
  data () {
    return {
      form: {
        serviceName: '',
        serviceUrl: '',
        servicePort: ''
      },
      services: [],
      error: '',
      loading: false,
      show: true
    }
  },
  created() {
    var firstSetup = window.settings.firstSetup
    if (!firstSetup) {
      this.getServicesConfig()
    }
  },
  computed: {
    disableServicesButtons() {
      return (this.services === undefined || this.services.length === 0)
    }
  },
  methods: {
    onSubmitServices(evt) {
      evt.preventDefault()
      this.loading = false
      this.error = ''
      if (this.services !== []) {
        /* Trick to reset/clear native browser form validation state */
        this.show = false
        this.$nextTick(() => { this.show = true })
        /* Storing the data */
        this.loading = true
        storeServices(this.services)
          .then(response => {
            this.servicesSet = true
            this.$emit('set-services', true)
            this.loading = false
          })
          .catch(err => {
            this.error = err.message
            this.loading = false
          })
      } else {
        this.error = 'Services cant be empty!'
      }
    },
    onResetServices(evt) {
      evt.preventDefault()
      this.services = []
      /* Reset our form values */
      /* Trick to reset/clear native browser form validation state */
      this.show = false
      this.$nextTick(() => { this.show = true })
    },
    getServicesConfig() {
      this.loading = false
      /* Trick to reset/clear native browser form validation state */
      this.show = false
      this.$nextTick(() => { this.show = true })
      /* Fetching the data */
      this.loading = true
      getConfig()
        .then(response => {
          this.services = response.data.services
          this.loading = false
        })
        .catch(err => {
          this.error = err.message
          this.loading = false
        })
    },
    addRow() {
      this.services.push({
        name: this.form.serviceName,
        url: this.form.serviceUrl,
        port: this.form.servicePort
      })
      this.form.serviceName = ''
      this.form.serviceUrl = ''
      this.form.servicePort = ''
    },
    deleteRow(index) {
      this.services.splice(index, 1)
    }
  }
}
</script>

<style scoped>
h2 {
  font-weight: normal;
}
.container {
  max-width: 1200px;
  margin:  0 auto;
}
.alerting {
  margin: 0 auto;
  text-align: center;
  display: block;
  line-height: 15px;
}
</style>
