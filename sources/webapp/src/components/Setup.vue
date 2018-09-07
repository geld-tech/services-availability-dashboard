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
                <div v-if="nowStep == 1" class="h-100 d-inline-block">
                    <h2>First Setup</h2>
                    <p>Welcome to the first setup!</p>
                    <p>The following pages will guide you through the configuration to start using you service.</p>
                </div>
                <div v-else-if="nowStep == 2" class="h-100 d-inline-block">
                    <h2>Admin Password</h2>
                    <p>Enter the system administration password in the following input field, then press Set</p>
                    <b-form @submit="onSubmit" @reset="onReset" id="adminPassword" v-if="show">
                        <b-form-input type="password" v-model="form.adminPassword" required></b-form-input>
                        <b-button type="reset" variant="danger">Clear</b-button>
                        <b-button type="submit" variant="primary">Set</b-button>
                    </b-form>
                </div>
                <div v-else-if="nowStep == 3" class="h-100 d-inline-block">
                    <h2>Google Analytics UA ID</h2>
                    <p>Enter the GA UA ID in the field below, then press Submit</p>
                    <b-form @submit="onSubmit" @reset="onReset" id="gaId" v-if="show">
                        <b-form-input type="password" v-model="form.gaId" required></b-form-input>
                        <b-button type="reset" variant="danger">Clear</b-button>
                        <b-button type="submit" variant="primary">Submit</b-button>
                    </b-form>
                </div>
                <div v-else-if="nowStep == 4" class="h-100 d-inline-block">
                    <p>Setup step 4</p>
                </div>
                <div v-else class="h-100 d-inline-block">
                    <p>Incorrect setup step</p>
                </div>
            </div>
            <div class="float-right">
              <b-button variant="primary" v-on:click="previousStep">Back</b-button>
              <b-button variant="primary" v-on:click="nextStep">Next</b-button>
            </div>
        </div>
    </b-container>
  </div>
</template>

<script>
import vueStep from 'vue-step'

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
        gaId: ''
      },
      nowStep: 1,
      stepList: ['First Setup', 'Password', 'Analytics', 'Services'],
      stepperStyle: 'style2',
      stepperColor: '#0079FB',
      show: true
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
    onReset (evt) {
      evt.preventDefault()
      /* Reset our form values */
      this.form.adminPassword = ''
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
.container {
  max-width: 1200px;
  margin:  0 auto;
}
.steps-container {
  height: 400px;
}
</style>
