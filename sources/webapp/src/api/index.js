import axios from 'axios'

export function fetchData() {
  var offset = -( new Date().getTimezoneOffset()/60 )
  var headers = { headers: { offset: offset } }
  return axios.get('/api/services/status/', headers).then(response => { return response.data }).catch(error => { /* console.error(error); */ return Promise.reject(error) })
}

export function fetchSearchData(keyword) {
  return axios.get('/api/services/status/' + keyword).then(response => { return response.data }).catch(error => { /* console.error(error); */ return Promise.reject(error) })
}

export function postPayload(url, payload) {
  axios.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded'
  return axios.post(url, payload).then(response => { return response.data }).catch(error => { /* console.error(error); */ return Promise.reject(error) })
}

export function storeAdminPassword(password) {
  var payload = { password: password }
  return postPayload('/setup/password/', payload)
}

export function storeGanalytics(uaid) {
  var payload = { uaid: uaid }
  axios.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded'
  return axios.post('/setup/ganalytics/', payload).then(response => { return response.data }).catch(error => { /* console.error(error); */ return Promise.reject(error) })
}

export function storeServices(services) {
  var payload = { services: services }
  axios.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded'
  return axios.post('/setup/services/', payload).then(response => { return response.data }).catch(error => { /* console.error(error); */ return Promise.reject(error) })
}

export function authenticate(password) {
  var payload = { password: password }
  return postPayload('/auth/login/', payload)
}

export function deauthenticate() {
  return postPayload('/auth/logout/')
}

export function getConfig() {
  return axios.get('/setup/config/').then(response => { return response.data }).catch(error => { /* console.error(error); */ return Promise.reject(error) })
}
