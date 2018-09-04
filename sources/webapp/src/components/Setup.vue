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
        </div>
    </b-container>
  </div>
</template>

<script>
export default {
  name: 'Info',
  props: ['loading', 'data'],
  components: {
    Status
  },
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
