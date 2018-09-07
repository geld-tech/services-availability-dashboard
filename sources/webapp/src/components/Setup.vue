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
            <div v-if="nowStep == 1">
                <h2>First Setup</h2>
                <p>Welcome to the first setup!</p>
                <p>The following pages will guide you through the configuration to start using you service.</p>
            </div>
            <div v-else-if="nowStep == 2">
                <p>Setup step 2</p>
            </div>
            <div v-else-if="nowStep == 3">
                <p>Setup step 3</p>
            </div>
            <div v-else-if="nowStep == 4">
                <p>Setup step 4</p>
            </div>
            <div v-else>
                <p>Incorrect setup step</p>
            </div>
            <div>
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
      nowStep: 1,
      stepList: ['First Setup', 'Password', 'Analytics', 'Services'],
      stepperStyle: 'style2',
      stepperColor: '#0079FB'
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
.Chart {
  background: #FFFFFF;
}
.Chart h2 {
  margin-top: 0;
  padding: 15px 0;
  border-bottom: 1px solid #323d54;
}
</style>
