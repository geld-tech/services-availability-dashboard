import axios from 'axios'

export function fetchData() {
  return axios.get('/api/services/status/').then(response => { return response.data }).catch(error => { /* console.error(error); */ return Promise.reject(error) })
}

export function fetchSearchData(keyword) {
  return axios.get('/api/services/status/' + keyword).then(response => { return response.data }).catch(error => { /* console.error(error); */ return Promise.reject(error) })
}

export function storeAdminPassword(password) {
  return axios.get('/setup/password/' + password).then(response => { return response.data }).catch(error => { /* console.error(error); */ return Promise.reject(error) })
}

export function storeGanalytics(uaid) {
  return axios.get('/setup/ganalytics/' + uaid).then(response => { return response.data }).catch(error => { /* console.error(error); */ return Promise.reject(error) })
}
