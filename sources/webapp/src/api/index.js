import axios from 'axios'

export function fetchData() {
  return axios.get('/api/services_status/').then(response => { return response.data }).catch(error => { /* console.error(error); */ return Promise.reject(error) })
}

export function fetchSearchData(keyword) {
  return axios.get('/api/services_status/' + keyword).then(response => { return response.data }).catch(error => { /* console.error(error); */ return Promise.reject(error) })
}
