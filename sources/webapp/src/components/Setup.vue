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
                    <h2>Admin Password</h2>
                    <div v-if="adminPasswordSet" class="pt-1">
                        <p>Password set successfully!</p>
                    </div>
                    <div v-else>
                        <p>Enter the system administration password in the following input field, then Submit</p>
                        <b-form @submit="onSubmitPassword" @reset="onResetPassword" id="adminPasswordForm" v-if="show">
                            <b-container fluid>
                              <b-row class="my-1">
                                <b-col sm="5"><label>Password</label></b-col>
                                <b-col sm="7"><b-form-input type="password" autocomplete="new-password" v-model="form.adminPassword" required></b-form-input></b-col>
                                <b-col sm="5"><label>Password (repeat)</label></b-col>
                                <b-col sm="7"><b-form-input type="password" autocomplete="new-password" v-model="form.adminPasswordRepeat" required></b-form-input></b-col>
                              </b-row>
                              <b-row class="my-1">
                                <b-col sm="10">
                                    <b-button type="reset" variant="danger" v-bind:disabled="disableAdminResetButton">Clear</b-button>
                                    <b-button type="submit" variant="primary" v-bind:disabled="disableAdminSubmitButton">Submit</b-button>
                                </b-col>
                              </b-row>
                              <b-row class="my-1">
                                <b-col md="6" offset-md="3">
                                   <!-- Alerting -->
                                   <div class="alerting">
                                     <b-alert :show="dismissCountDown" dismissible variant="danger" @dismissed="error=''" @dismiss-count-down="countDownChanged">
                                       <p>{{ error }}</p>
                                     </b-alert>
                                   </div>
                                </b-col>
                              </b-row>
                            </b-container>
                        </b-form>
                    </div>
                </div>
                <div v-else-if="nowStep == 3" class="h-100 d-inline-block pt-5">
                    <h2>Google Analytics</h2>
                    <div v-if="ganalyticsIdSet" class="pt-1">
                        <p>Analytics UA ID set successfully!</p>
                    </div>
                    <div v-else>
                        <p>Enter the Google Analytics UA ID in the field below (optional), then press Submit</p>
                        <b-form @submit="onSubmitGaId" @reset="onResetGaId" id="uaid" v-if="show">
                            <b-container fluid>
                              <b-row class="my-1">
                                <b-col sm="4"><label>Google Analytics UA ID</label></b-col>
                                <b-col sm="6"><b-form-input type="text" autocomplete="new-password" v-model="form.uaid" required></b-form-input></b-col>
                              </b-row>
                              <b-row class="my-1">
                                <b-col sm="10">
                                  <b-button type="reset" variant="danger" v-bind:disabled="disableGaIdButtons">Clear</b-button>
                                  <b-button type="submit" variant="primary" v-bind:disabled="disableGaIdButtons">Submit</b-button>
                                </b-col>
                              </b-row>
                            </b-container>
                        </b-form>
                    </div>
                </div>
                <div v-else-if="nowStep == 4" class="h-100 d-inline-block pt-5">
                    <h2>Services Availability</h2>
                    <p>Enter the name, URL and port of the service(s) to monitor the availability for:</p>
                    <b-form @submit="onSubmitService" @reset="onResetService" id="serviceForm" v-if="show">
                        <b-container fluid>
                          <b-row class="my-1" no-gutters>
                            <b-col sm="5"><label>Service Name</label></b-col>
                            <b-col sm="4"><label>URL</label></b-col>
                            <b-col sm="2"><label>Port</label></b-col>
                            <b-col sm="1"></b-col>
                          </b-row>
                          <b-row class="my-1" no-gutters v-if="services" v-for="(service, index) in services" v-bind:key="index">
                            <b-col sm="5">{{ service.name }}</b-col>
                            <b-col sm="4">{{ service.url }}</b-col>
                            <b-col sm="2">{{ service.port }}</b-col>
                            <b-col sm="1"><b-button @click="deleteRow(index)"><strong> - </strong></b-button></b-col>
                          </b-row>
                          <b-row class="my-1" no-gutters>
                            <b-col sm="5"><b-form-input type="text" v-model="form.serviceName"></b-form-input></b-col>
                            <b-col sm="4"><b-form-input type="text" v-model="form.serviceUrl"></b-form-input></b-col>
                            <b-col sm="2"><b-form-input type="text" v-model="form.servicePort"></b-form-input></b-col>
                            <b-col sm="1"><b-button @click="addRow"><strong> + </strong></b-button></b-col>
                          </b-row>
                          <b-row class="my-1" no-gutters>
                            <b-col sm="10">
                              <b-button type="reset" variant="danger">Clear</b-button>
                              <b-button type="submit" variant="primary">Save</b-button>
                            </b-col>
                          </b-row>
                        </b-container>
                    </b-form>
                </div>
                <div v-else class="h-100 d-inline-block pt-5">
                    <h2>Error</h2>
                    <p>Incorrect setup step</p>
                </div>
            </div>
            <div class="float-right">
              <b-button variant="primary" v-on:click="previousStep" v-bind:disabled="nowStep == 1">Back</b-button>
              <b-button variant="primary"
                v-on:click="nextStep"
                v-bind:disabled="nowStep == stepList.length ||
                    (nowStep > 1 && !adminPasswordSet) ||
                    (nowStep > 2 && !ganalyticsIdSet)" autofocus>Next</b-button>
            </div>
        </div>
    </b-container>
  </div>
</template>

<script>
import vueStep from 'vue-step'
import { storeAdminPassword, storeGanalytics } from '@/api'

export default {
  name: 'Info',
  props: ['loading', 'data'],
  components: {
    vueStep
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
      error: '',
      show: true,
      adminPasswordSet: false,
      ganalyticsIdSet: false,
      services: []
    }
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
    onSubmitPassword(evt) {
      evt.preventDefault()
      var password = this.sanitizeString(this.form.adminPassword)
      var passwordRepeat = this.sanitizeString(this.form.adminPasswordRepeat)
      this.form.adminPassword = ''
      this.form.adminPasswordRepeat = ''
      this.loading = false
      this.dismissCountDown = 0
      this.error = ''
      if (password !== '' && password === passwordRepeat) {
        /* Trick to reset/clear native browser form validation state */
        this.data = []
        this.show = false
        this.$nextTick(() => { this.show = true })
        /* Fetching the data */
        this.loading = true
        storeAdminPassword(password)
          .then(response => {
            this.data = response.data
            this.loading = false
            this.adminPasswordSet = true
          })
          .catch(err => {
            this.error = err.message
            this.loading = false
            this.dismissCountDown = 6
          })
      } else {
        this.error = 'Passwords dont match!'
        this.dismissCountDown = 6
      }
    },
    onResetPassword(evt) {
      evt.preventDefault()
      /* Reset our form values */
      this.form.adminPassword = ''
      this.form.adminPasswordRepeat = ''
      /* Trick to reset/clear native browser form validation state */
      this.show = false
      this.$nextTick(() => { this.show = true })
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
    onSubmitService(evt) {
      evt.preventDefault()
      this.loading = false
      this.error = ''
      if (this.error !== '') {
        /* Trick to reset/clear native browser form validation state */
        this.data = []
        this.show = false
        this.$nextTick(() => { this.show = true })
        /* Fetching the data */
      } else {
        this.error = 'GA UA ID cant be empty!'
      }
    },
    onResetService(evt) {
      evt.preventDefault()
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
    },
    deleteRow(index) {
      this.services.splice(index, 1)
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
