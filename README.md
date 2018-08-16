# services-availability-dashboard

## Status

<table>
    <thead>
      <tr class="table">
        <th>Ubuntu/Debian</th>
        <th>CentOS/Red Hat</th>
        <th>Build Status</th>
        <th>License</th>
      </tr>
    </thead>
    <tbody class="odd">
      <tr>
        <td>
            <a href="https://bintray.com/geldtech/debian/services-availability-monitor#files">
                <img src="https://api.bintray.com/packages/geldtech/debian/services-availability-monitor/images/download.svg" alt="Download DEBs">
            </a>
        </td>
        <td>
            <a href="https://bintray.com/geldtech/rpm/services-availability-monitor#files">
                <img src="https://api.bintray.com/packages/geldtech/rpm/services-availability-monitor/images/download.svg" alt="Download RPMs">
            </a>
        </td>
        <td>
            <a href="https://travis-ci.org/geld-tech/services-availability-monitor">
                <img src="https://travis-ci.org/geld-tech/services-availability-monitor.svg?branch=master" alt="Build Status">
            </a>
        </td>
        <td>
            <a href="https://opensource.org/licenses/Apache-2.0">
                <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" alt="">
            </a>
        </td>
      </tr>
    </tbody>
</table>


## Description

Dashboard displaying availability and latency to configured services based on Python Flask, Vue.js, and Chart.js 


## Demo

A sample demo of the project is hosted on <a href="http://geld.tech">geld.tech</a>.


## Install

### Ubuntu/Debian

* Install the repository information and associated GPG key (to ensure authenticity):
```
$ echo "deb https://dl.bintray.com/geldtech/debian /" | sudo tee -a /etc/apt/sources.list.d/geld-tech.list
$ sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com EA3E6BAEB37CF5E4
```

* Update repository list of available packages and clean already installed versions
```
$ sudo apt update
$ sudo apt clean
```

* Install package
```
$ sudo apt install services-availability-monitor
```

### CentOS/Red Hat

* Install the repository by creating the file /etc/yum.repos.d/zlig.repo:

```
echo "[geld.tech]
name=geld.tech
baseurl=https://dl.bintray.com/geldtech/rpm
gpgcheck=0
repo_gpgcheck=0
enabled=1" | sudo tee -a /etc/yum.repos.d/geld.tech.repo
```

* Install the package
```
sudo yum install services-availability-monitor
```


## Usage

* Adds Google Analytics User Agent ID (optional)
  * Edit configuration file
  ```
  vim /opt/geld/webapps/services-availability-monitor/config/settings.cfg
  ```

  * Replace <GA_UA_ID> with own value
  ```
  [ganalytics]
  ua_id=<GA_UA_ID>
  ```

* Reload systemd services configuration and start services-availability-monitor service
```
$ sudo systemctl daemon-reload
$ sudo systemctl start services-availability-monitor
$ sudo systemctl status services-availability-monitor
```


## Development

Use `local-dev.sh` script to build and run locally the Flask server with API, a stub Nginx status, and the Vue web application with DevTools enabled for [Firefox](https://addons.mozilla.org/en-US/firefox/addon/vue-js-devtools/) and [Chrome](https://chrome.google.com/webstore/detail/vuejs-devtools/nhdogjmejiglipccpnnnanhbledajbpd):

```
$ ./local-dev.sh
```
Then, access the application locally using a browser at the address: [http://0.0.0.0:5000/](http://0.0.0.0:5000/).

Press <CTRL+C> at any stage to stop the local development application.
