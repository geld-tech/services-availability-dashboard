import axios from 'axios'

export function fetchData() {
  return axios.get('/api/services/status/').then(response => { return response.data }).catch(error => { /* console.error(error); */ return Promise.reject(error) })
}

export function fetchSearchData(keyword) {
  return axios.get('/api/services/status/' + keyword).then(response => { return response.data }).catch(error => { /* console.error(error); */ return Promise.reject(error) })
}

export function storeAdminPassword(password) {
  var payload = { password: password }
  axios.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded'
  return axios.post('/setup/password/', payload).then(response => { return response.data }).catch(error => { /* console.error(error); */ return Promise.reject(error) })
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

export function postPayload(url, data) {
  var payload = { data: data }
  axios.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded'
  return axios.post(url, payload).then(response => { return response.data }).catch(error => { /* console.error(error); */ return Promise.reject(error) })
}
