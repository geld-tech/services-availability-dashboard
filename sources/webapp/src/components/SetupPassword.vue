<template>
    <div>
        <h2>Admin Password</h2>
        <div v-if="adminPasswordSet" class="pt-1">
            <p>Password set successfully!</p>
        </div>
        <div v-else>
            <p>Enter the system administration password in the following input field, then Submit</p>
            <b-form @submit="onSubmitPassword" @reset="onResetPassword" id="adminPasswordForm" v-if="show">
                <b-container fluid>
                  <b-row class="my-1">
                    <b-col sm="5">
                        <label>Password</label>
                    </b-col>
                    <b-col sm="7">
                        <b-form-input type="password" autocomplete="new-password" v-model="form.adminPassword" id="adminPassword" required></b-form-input>
                    </b-col>
                    <b-col sm="5">
                        <label>Password (repeat)</label>
                    </b-col>
                    <b-col sm="7">
                        <b-form-input type="password" autocomplete="new-password" v-model="form.adminPasswordRepeat" id="adminPasswordRepeat" required></b-form-input>
                    </b-col>
                  </b-row>
                  <b-row class="my-1">
                    <b-col sm="10">
                        <b-button type="reset" variant="danger" v-bind:disabled="disableAdminResetButton" id="adminResetButton">Clear</b-button>
                        <b-button type="submit" variant="primary" v-bind:disabled="disableAdminSubmitButton" id="adminSubmitButton">Submit</b-button>
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
</template>

<script>
import { storeAdminPassword } from '@/api'

export default {
  name: 'SetupPassword',
  props: ['loading', 'data', 'adminPasswordSet'],
  data () {
    return {
      form: {
        adminPassword: '',
        adminPasswordRepeat: ''
      },
      error: '',
      show: true
    }
  },
  computed: {
    disableAdminResetButton() {
      return (this.form.adminPassword === '' && this.form.adminPasswordRepeat === '')
    },
    disableAdminSubmitButton() {
      return (this.form.adminPassword === '' || this.form.adminPasswordRepeat === '' || this.form.adminPassword !== this.form.adminPasswordRepeat)
    }
  },
  methods: {
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
            this.$emit('adminPasswordSet', true)
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
    sanitizeString(input) {
      input = input.trim()
      input = input.replace(/[`~!$%^&*|+?;:'",\\]/gi, '')
      input = input.replace('/', '')
      input = input.trim()
      return input
    },
    onResetPassword(evt) {
      evt.preventDefault()
      /* Reset our form values */
      this.form.adminPassword = ''
      this.form.adminPasswordRepeat = ''
      /* Trick to reset/clear native browser form validation state */
      this.show = false
      this.$nextTick(() => { this.show = true })
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
