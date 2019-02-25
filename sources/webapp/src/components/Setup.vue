<template>
  <div class="index">
    <!-- Container -->
    <b-container class="bv-example-row">
        <div v-if="loading" class="loading">
            <h6>Loading...</h6>
            <img src="/static/images/spinner.gif" width="32" height="32"/>
        </div>
        <div v-else>
            <vue-step v-bind:now-step="nowStep" v-bind:step-list="stepList" v-bind:style-type="stepperStyle" v-bind:active-color="stepperColor"></vue-step>
            <div class="text-center steps-container">
                <div v-if="nowStep == 1" class="h-100 d-inline-block pt-5">
                    <h2>First Setup</h2>
                    <p>Welcome to the first setup!</p>
                    <p>The following pages will guide you through the configuration to start using you service.</p>
                </div>
                <div v-else-if="nowStep == 2" class="h-100 d-inline-block pt-5">
                    <setup-password
                        v-on:set-admin-password="adminPasswordSet = $event">
                    </setup-password>
                </div>
                <div v-else-if="nowStep == 3" class="h-100 d-inline-block pt-5">
                    <h2>Google Analytics</h2>
                    <div v-if="ganalyticsIdSet" class="pt-1">
                        <p>Analytics UA ID set successfully!</p>
                    </div>
                    <div v-else>
                        <p>Enter the Google Analytics UA ID in the field below, then press Submit</p>
                        <b-form @submit="onSubmitGaId" @reset="onResetGaId" id="uaid" v-if="show">
                            <b-container fluid>
                              <b-row class="my-1">
                                <b-col sm="5">
                                    <label>Google Analytics UA ID</label>
                                </b-col>
                                <b-col sm="7">
                                    <b-form-input type="text" v-model="form.uaid" id="uaIdInput" required></b-form-input>
                                </b-col>
                              </b-row>
                              <b-row class="my-1">
                                <b-col sm="12">
                                  <b-button type="reset" variant="danger" v-bind:disabled="disableGaIdButtons" id="uaidClearButton">Clear</b-button>
                                  <b-button type="submit" variant="primary" v-bind:disabled="disableGaIdButtons" id="uaidAdminButton">Submit</b-button>
                                </b-col>
                              </b-row>
                            </b-container>
                        </b-form>
                    </div>
                </div>
                <div v-else-if="nowStep == 4" class="h-100 d-inline-block pt-5">
                    <h2>Services Availability</h2>
                    <div v-if="servicesSet" class="pt-1">
                        <p>Services Availability monitor successfully configured!</p>
                        <p>Press Next to start using the application.</p>
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
                <div v-else class="h-100 d-inline-block pt-5">
                    <h2>Error</h2>
                    <p>Incorrect setup step</p>
                </div>
            </div>
            <div class="float-right" v-if="servicesSet">
              <b-button variant="primary" id="backButton" disabled>Back</b-button>
              <b-button variant="primary" v-on:click="startApplication" id="startButton" autofocus>Start</b-button>
            </div>
            <div class="float-right" v-else>
              <b-button variant="primary" v-on:click="previousStep" v-bind:disabled="nowStep == 1" id="defaultBackButton">Back</b-button>
              <b-button variant="primary"
                v-on:click="nextStep"
                v-bind:disabled="nowStep == stepList.length ||
                    (nowStep > 1 && !adminPasswordSet) ||
                    (nowStep > 2 && !ganalyticsIdSet)"
                id="nextButton" autofocus>Next</b-button>
            </div>
        </div>
    </b-container>
  </div>
</template>

<script>
import vueStep from 'vue-step'
import { storeGanalytics, storeServices } from '@/api'
import SetupPassword from '@/components/SetupPassword'

export default {
  name: 'Setup',
  props: ['loading', 'data'],
  components: {
    vueStep,
    'setup-password': SetupPassword
  },
  data () {
    return {
      form: {
        adminPassword: '',
        adminPasswordRepeat: '',
        uaid: '',
        serviceName: '',
        serviceUrl: '',
        servicePort: ''
      },
      nowStep: 1,
      stepList: ['First Setup', 'Admin Password', 'Google Analytics', 'Services'],
      stepperStyle: 'style2',
      stepperColor: '#0079FB',
      dismissCountDown: 0,
      adminPasswordSet: false,
      ganalyticsIdSet: false,
      servicesSet: false,
      services: [],
      error: '',
      show: true
    }
  },
  created() {
    var firstSetup = window.settings.firstSetup
    if (!firstSetup) {
      this.$router.push({name: 'Index'})
    }
    window.clearInterval(this.refreshInterval)
  },
  computed: {
    disableAdminResetButton() {
      return (this.form.adminPassword === '' && this.form.adminPasswordRepeat === '')
    },
    disableAdminSubmitButton() {
      return (this.form.adminPassword === '' || this.form.adminPasswordRepeat === '' || this.form.adminPassword !== this.form.adminPasswordRepeat)
    },
    disableGaIdButtons() {
      return (this.form.uaid === '')
    },
    disableServicesButtons() {
      return (this.services === undefined || this.services.length === 0)
    }
  },
  methods: {
    nextStep() {
      if (this.nowStep < this.stepList.length) {
        this.nowStep += 1
      } else {
        this.nowStep = this.stepList.length
      }
    },
    previousStep() {
      if (this.nowStep > 1) {
        this.nowStep -= 1
      } else {
        this.nowStep = 1
      }
    },
    onSubmitGaId(evt) {
      evt.preventDefault()
      var uaid = this.sanitizeString(this.form.uaid)
      this.form.uaid = ''
      this.loading = false
      this.error = ''
      if (uaid !== '') {
        /* Trick to reset/clear native browser form validation state */
        this.data = []
        this.show = false
        this.$nextTick(() => { this.show = true })
        /* Fetching the data */
        this.loading = true
        storeGanalytics(uaid)
          .then(response => {
            this.data = response.data
            this.loading = false
            this.ganalyticsIdSet = true
          })
          .catch(err => {
            this.error = err.message
            this.loading = false
          })
      } else {
        this.error = 'GA UA ID cant be empty!'
      }
    },
    onResetGaId(evt) {
      evt.preventDefault()
      /* Reset our form values */
      this.form.uaid = ''
      /* Trick to reset/clear native browser form validation state */
      this.show = false
      this.$nextTick(() => { this.show = true })
    },
    onSubmitServices(evt) {
      evt.preventDefault()
      this.loading = false
      this.error = ''
      if (this.services !== []) {
        /* Trick to reset/clear native browser form validation state */
        this.data = []
        this.show = false
        this.$nextTick(() => { this.show = true })
        /* Storing the data */
        this.loading = true
        storeServices(this.services)
          .then(response => {
            this.data = response.data
            this.servicesSet = true
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
    sanitizeString(input) {
      input = input.trim()
      input = input.replace(/[`~!$%^&*|+?;:'",\\]/gi, '')
      input = input.replace('/', '')
      input = input.trim()
      return input
    },
    countDownChanged (dismissCountDown) {
      this.dismissCountDown = dismissCountDown
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
    },
    startApplication() {
      this.$router.push('/')
    }
  }
}
</script>

<style scoped>
h1, h2 {
  font-weight: normal;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
.processesTable{
  font-size: 14px;
}
.loading {
  width: 50%;
  margin: 0;
  padding-top: 40px;
  padding-left: 40px;
}
.container {
  max-width: 1200px;
  margin:  0 auto;
}
.steps-container {
  height: 400px;
}
.alerting {
  margin: 0 auto;
  text-align: center;
  display: block;
  line-height: 15px;
}
</style>
