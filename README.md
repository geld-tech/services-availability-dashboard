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
            <a href="https://bintray.com/geldtech/debian/services-availability-dashboard#files">
                <img src="https://api.bintray.com/packages/geldtech/debian/services-availability-dashboard/images/download.svg" alt="Download DEBs">
            </a>
        </td>
        <td>
            <a href="https://bintray.com/geldtech/rpm/services-availability-dashboard#files">
                <img src="https://api.bintray.com/packages/geldtech/rpm/services-availability-dashboard/images/download.svg" alt="Download RPMs">
            </a>
        </td>
        <td>
            <a href="https://travis-ci.org/geld-tech/services-availability-dashboard">
                <img src="https://travis-ci.org/geld-tech/services-availability-dashboard.svg?branch=master" alt="Build Status">
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
echo "deb http://dl.bintray.com/geldtech/debian /" |  tee -a /etc/apt/sources.list.d/geld-tech.list
 apt-key adv --recv-keys --keyserver keyserver.ubuntu.com EA3E6BAEB37CF5E4
```

* Update repository list of available packages and clean already installed versions
```
 apt clean all
 apt update
```

* Install package
```
 apt install services-availability-dashboard
```

### CentOS/Red Hat

* Install the repository by creating the file /etc/yum.repos.d/zlig.repo:
```
echo "[geld.tech]
name=geld.tech
baseurl=http://dl.bintray.com/geldtech/rpm
gpgcheck=0
repo_gpgcheck=0
enabled=1" |  tee -a /etc/yum.repos.d/geld.tech.repo
```

* Install EPEL repository for external dependencies
```
 yum install epel-release
```

* Install the package
```
 yum install services-availability-dashboard
```

### Docker

Installation on Docker is similar to the base image, CentOS or Ubuntu, but with the following differences pre-requisites.

* Install Python and wget (if not installed yet)
  * CentOS-based image: `yum install -y python wget`
  * Ubuntu-based image: `apt install -y python wget`
* Download Docker systemctl replacement
```
wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py
```
* Replace systemctl (which doesn't work on Docker as PIDs aren't starting at 1):
```
cp systemctl.py /usr/bin/systemctl
test -L /bin/systemctl || ln -sf /usr/bin/systemctl /bin/systemctl
```

## Usage

* Adds Google Analytics User Agent ID (optional)
  * Edit configuration file
  ```
  vim /opt/geld/webapps/services-availability-dashboard/config/settings.cfg
  ```

  * Replace <GA_UA_ID> with own value
  ```
  [ganalytics]
  ua_id=<GA_UA_ID>
  ```

* Reload systemd services configuration and start services-availability-dashboard service
```
 systemctl daemon-reload
 systemctl start services-availability-dashboard
 systemctl status services-availability-dashboard
```


## Development

Use `local-dev.sh` script to build and run locally the Flask server with API, a stub Nginx status, and the Vue web application with DevTools enabled for [Firefox](https://addons.mozilla.org/en-US/firefox/addon/vue-js-devtools/) and [Chrome](https://chrome.google.com/webstore/detail/vuejs-devtools/nhdogjmejiglipccpnnnanhbledajbpd):

```
./local-dev.sh
```
Then, access the application locally using a browser at the address: [http://0.0.0.0:5000/](http://0.0.0.0:5000/).

Press <CTRL+C> at any stage to stop the local development application.
