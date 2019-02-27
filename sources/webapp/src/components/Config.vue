<template>
  <div class="index">
    <!-- Container -->
    <b-container class="bv-example-row">
        <h2>Configuration</h2>
        <div v-if="loggedIn" class="pt-1">
            <p>Configuration updated successfully!</p>
        </div>
        <div v-else>
            <setup-password v-bind:adminPasswordSet="adminPasswordSet" v-on:set-admin-password="adminPasswordSet = $event">
            </setup-password>
        </div>
    </b-container>
  </div>
</template>

<script>
import SetupPassword from '@/components/SetupPassword'

export default {
  name: 'Config',
  props: ['loggedIn'],
  components: {
    'setup-password': SetupPassword
  },
  data () {
    return {
      adminPasswordSet: false,
      error: '',
      show: true
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
