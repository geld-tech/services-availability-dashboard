<template>
  <div class="index">
    <!-- Container -->
    <b-container v-if="authenticated" class="bv-example-row">
        <h2>Configuration</h2>
        <b-card no-body>
            <b-tabs pills card vertical>
              <b-tab title="Admin Password" id="admin-password-tab" active>
                <div class="component">
                    <div class="pt-1">
                        <p>Configuration updated successfully!</p>
                    </div>
                    <div class="component">
                        <setup-password v-bind:adminPasswordSet="adminPasswordSet" v-on:set-admin-password="adminPasswordSet = $event">
                        </setup-password>
                    </div>
                </div>
              </b-tab>
              <b-tab title="Services" id="services-tab">
                <div class="component">
                    <setup-services v-bind:servicesSet="servicesSet" v-on:set-services="servicesSet = $event">
                    </setup-services>
                </div>
               </b-tab>
              <b-tab title="Analytics" id="analytics-tab">
                <div class="component">
                    <setup-ganalytics v-bind:ganalyticsIdSet="ganalyticsIdSet" v-on:set-ganalytics-uaid="ganalyticsIdSet = $event">
                    </setup-ganalytics>
                </div>
               </b-tab>
            </b-tabs>
        </b-card>
    </b-container>
    <b-container class="bv-example-row">
        <div>
            <login v-bind:authenticated="authenticated" v-on:set-authenticated="authenticated = $event">
            </login>
        </div>
    </b-container>
  </div>
</template>

<script>
import Login from '@/components/Login'
import SetupPassword from '@/components/SetupPassword'
import SetupServices from '@/components/SetupServices'
import SetupGanalytics from '@/components/SetupGanalytics'

export default {
  name: 'Config',
  components: {
    'login': Login,
    'setup-password': SetupPassword,
    'setup-services': SetupServices,
    'setup-ganalytics': SetupGanalytics
  },
  data () {
    return {
      authenticated: false,
      adminPasswordSet: false,
      servicesSet: false,
      ganalyticsIdSet: false
    }
  }
}
</script>

<style scoped>
h2 {
  font-weight: normal;
}
.component {
  height: 500px;
}
.alerting {
  margin: 0 auto;
  text-align: center;
  display: block;
  line-height: 15px;
}
</style>
