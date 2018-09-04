<template>
  <div class="index">
    <!-- Container -->
    <b-container class="bv-example-row">
        <div v-if="loading" class="loading">
            <h6>Loading...</h6>
            <img src="/static/images/spinner.gif" width="32" height="32"/>
        </div>
        <div v-else>
            <h3>{{ msg }}</h3>
                <stepper buttons>
                  <step name="Basic Information"
                        icon="folder-open-o"
                        slot="content">
                    <h3 class="font-weight-bold pl-0 my-4"><strong>Basic Information</strong></h3>
                    <md-input label="Email"/>
                    <md-input label="Username"/>
                    <md-input label="Password"/>
                    <md-input label="Repeat Password"/>
                  </step>

                  <step name="Personal Data"
                        icon="pencil"
                        slot="content">
                    <h3 class="font-weight-bold pl-0 my-4"><strong>Personal Data</strong></h3>
                    <md-input label="First Name"/>
                    <md-input label="Second Name"/>
                    <md-input label="Surname"/>
                    <md-textarea label="Address"/>
                  </step>

                  <step name="Terms and Conditions"
                        icon="photo"
                        slot="content">
                    <h3 class="font-weight-bold pl-0 my-4"><strong>Terms and conditions</strong></h3>
                    <md-input type="checkbox" id="checkbox1" label="I agree to the terms and conditions" />
                    <md-input type="checkbox" id="checkbox2" label="I want to receive newsletter" />
                  </step>
                  <step name="Finish"
                        icon="check"
                        slot="content">
                    <h3 class="font-weight-bold pl-0 my-4"><strong>Finish</strong></h3>
                    <h2 class="text-center font-weight-bold my-4">Registration completed!</h2>
                  </step>
                </stepper>
        </div>
    </b-container>
  </div>
</template>

<script>
export default {
  name: 'Info',
  props: ['loading', 'data'],
  data () {
    return {
      msg: 'First Setup'
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
a {
  color: #42b983;
}
.processesTable{
  font-size: 14px;
}
.container {
  max-width: 800px;
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
