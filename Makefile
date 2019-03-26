LOCAL_DEV_ENV=local-dev-env
LOCAL_CACHE=.cache
SRV_DEV_ENV=local-dev-env/server
NPM_DEV_ENV=local-dev-env/webapp

## Run all targets locally
all: stop save-cache clean isort lint test local-dev-env vue-dev-tools npm-install npm-lint npm-audit npm-build webapp-setup webapp-settings
	@echo "Build completed successfully!"

## Remove all local build artifacts
clean: stop clean-pyc
	$(call echo_title, "LOCAL DEV ENV CLEANUP")
	rm -rf $(LOCAL_DEV_ENV)

## Remove python artifacts
clean-pyc:
	$(call echo_title, "PYTHON FILES CLEANUP")
	find . -name '*.pyc' -exec rm --force {} +
	find . -name '*.pyo' -exec rm --force {} +

## Clean all files including cache for NPM
clean-all: clean
	$(call echo_title, "CACHE FILES CLEANUP")
	-rm -rf $(LOCAL_CACHE)

## Save NPM cache
save-cache:
	$(call echo_title, "SAVE CACHE")
	@echo "== NPM =="
	@if [ -d "$(LOCAL_DEV_ENV)/webapp/node_modules/" ]; then \
	    rm -rf $(LOCAL_CACHE)/node_modules/; \
	    mkdir -p $(LOCAL_CACHE); \
	    mv $(LOCAL_DEV_ENV)/webapp/node_modules/ $(LOCAL_CACHE) ||: ; \
	fi

## Sort Python import statements
isort:
	$(call echo_title, "PYTHON ISORT")
	sh -c "isort --skip-glob=.tox --recursive sources/server/ "

## Check coding style of Flask application, enforce no syntax errors or undefined names, and flags other issues
lint:
	$(call echo_title, "PYTHON LINTER")
	flake8 sources/server/ --show-source --max-line-length=239 --max-complexity=10 --statistics --count

## Run unit tests
test:
	$(call echo_title, "PYTHON UNIT TESTS")
	python -m unittest discover -s tests

## Prepare local development environment
local-dev-env:
	$(call echo_title, "LOCAL DEV ENV")
	@echo "== Prepare folders =="
	mkdir -p $(LOCAL_DEV_ENV)
	cp -r sources/server/ $(LOCAL_DEV_ENV)
	cp -r sources/webapp/ $(LOCAL_DEV_ENV)
	@echo "== Replace place holders =="
	find $(LOCAL_DEV_ENV) -type f | xargs sed -i "s/__PACKAGE_NAME__/localdev/g"
	find $(LOCAL_DEV_ENV) -type f | xargs sed -i "s/__PACKAGE_DESC__/Running application locally/g"
	find $(LOCAL_DEV_ENV) -type f | xargs sed -i "s/__PACKAGE_AUTHOR__/geld.tech/g"
	find $(LOCAL_DEV_ENV) -type f | xargs sed -i "s/__VERSION__/0.0.1/g"
	find $(LOCAL_DEV_ENV) -type f | xargs sed -i "s/__DATE__/01-01-1970/g"
	@if [ -d "$(LOCAL_CACHE)/node_modules/" ]; then \
		echo "== Restore NPM cache =="; \
		set -x; \
		mv $(LOCAL_CACHE)/node_modules/ $(LOCAL_DEV_ENV)/webapp/ ||: ; \
		set +x; \
	fi

## Ensure Vue application is built with DevTools enabled (requires Firefox or Chrome plugin)
vue-dev-tools:
	$(call echo_title, "VUE DEVTOOLS")
	sed -i '/Vue.config.productionTip = false/a Vue.config.devtools = true' $(LOCAL_DEV_ENV)/webapp/src/main.js

## Install NPM Modules in local dev environment
npm-install: local-dev-env
	$(call echo_title, "NPM INSTALL")
	cd $(NPM_DEV_ENV) ; npm install

## Runs linter on Vue web application files
npm-lint: npm-install
	$(call echo_title, "NPM LINT")
	cd $(NPM_DEV_ENV) ; npm run lint

## Runs NPM audit to flag security issues
npm-audit: npm-install
	$(call echo_title, "NPM AUDIT") # Run conditionally as not installed on all systems
	-cd $(NPM_DEV_ENV) ; npm audit 2> /dev/null # Failures ignored locally with -, but will be executed on Travis before distribution

## Runs a full build using NPM
npm-build: npm-install
	$(call echo_title, "NPM BUILD")
	cd $(NPM_DEV_ENV) ; npm run build

## Prepare application
webapp-setup: npm-build
	$(call echo_title, "PREPARE")
	mkdir $(SRV_DEV_ENV)/templates/
	mkdir $(SRV_DEV_ENV)/static/
	cp $(NPM_DEV_ENV)/dist/*.html $(SRV_DEV_ENV)/templates/
	cp -r $(NPM_DEV_ENV)/dist/static/* $(SRV_DEV_ENV)/static/

## Create a stub settings.cfg file
webapp-settings:
	$(call echo_title, "CREATE STUB SETTINGS")
	@touch $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "[admin]" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "password = Y25mZmpiZXExMjM=" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "[ganalytics]" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "ua_id = 1234567" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "[services]" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "geld.tech = https://geld.tech" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "wikipedia = https://en.wikipedia.org" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "yahoo.co.jp = https://www.yahoo.co.jp" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "google = https://www.google.com" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "youtube = https://www.youtube.com" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "facebook = https://www.facebook.com" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "baidu = https://www.baidu.com" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "qq = https://www.qq.com" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "Taobao = https://www.taobao.com" >> $(SRV_DEV_ENV)/config/settings.cfg.dev

## Configure stub settings.cfg
webapp-config: webapp-settings
	$(call echo_title, "SETUP STUB SETTINGS")
	cp -f $(SRV_DEV_ENV)/config/settings.cfg.dev $(SRV_DEV_ENV)/config/settings.cfg

## Start metrics collector daemon
daemon-start:
	$(call echo_title, "START METRICS DAEMON")
	@echo "Starting stub background daemon locally, use 'make daemon-stop' to terminate.."
	@echo ""
	python $(SRV_DEV_ENV)/monitor-collectord.py start debug
	@echo ""
	@sleep 3

## Stop metrics collector daemon
daemon-stop:
	$(call echo_title, "STOP METRICS DAEMON")
	-python $(SRV_DEV_ENV)/monitor-collectord.py stop
	-pkill -f $(SRV_DEV_ENV)/monitor-collectord.py

## Start web application
webapp-start:
	$(call echo_title, "START WEB APPLICATION")
	@echo "Starting web application locally, use 'make webapp-stop' to terminate.."
	@echo ""
	python $(SRV_DEV_ENV)/application.py &
	@echo ""
	@sleep 1

## Stop web application
webapp-stop:
	$(call echo_title, "STOP WEB APPLICATION")
	-pkill -f $(SRV_DEV_ENV)/application.py

## Start local development environment
start: all daemon-start webapp-start

## Stop local development environment
stop: daemon-stop webapp-stop

## Validate latest .deb package on a local Ubuntu image with Docker
docker-run-deb:
	sudo docker run -i -t -p 8005:8005 --rm ubuntu:xenial /bin/bash -c ' apt clean all && apt update && apt install -y python wget vim ; \
		wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py ; \
		cp /usr/bin/systemctl /usr/bin/systemctl.bak ; \
		yes | cp -f systemctl.py /usr/bin/systemctl ; \
		chmod a+x /usr/bin/systemctl ; \
		test -L /bin/systemctl || ln -sf /usr/bin/systemctl /bin/systemctl ; \
		echo "deb http://dl.bintray.com/geldtech/debian /" |  tee -a /etc/apt/sources.list.d/geld-tech.list ; \
		apt-key adv --recv-keys --keyserver keyserver.ubuntu.com EA3E6BAEB37CF5E4 ; \
		apt clean all ; \
		apt update ; \
		apt install -y services-availability-dashboard ; \
		systemctl status services-availability-dashboard ; \
		systemctl status services-availability-dashboard-collector ; \
		$$SHELL '

## Validate latest .rpm package on a local CentOS image with Docker
docker-run-rpm:
	sudo docker run -i -t -p 8005:8005 --rm centos:7 /bin/bash -c ' yum clean all && yum install -y python wget vim ; \
		yum install -y epel-release ; \
		wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py ; \
		cp /usr/bin/systemctl /usr/bin/systemctl.bak ; \
		yes | cp -f systemctl.py /usr/bin/systemctl ; \
		chmod a+x /usr/bin/systemctl ; \
		test -L /bin/systemctl || ln -sf /usr/bin/systemctl /bin/systemctl ; \
		useradd -MU www-data && usermod -L www-data ; \
		echo -e "[geld.tech]\nname=geld.tech\nbaseurl=http://dl.bintray.com/geldtech/rpm\ngpgcheck=0\nrepo_gpgcheck=0\nenabled=1" | \
			tee -a /etc/yum.repos.d/geld.tech.repo ; \
		yum install -y services-availability-dashboard ; \
		systemctl status services-availability-dashboard ; \
		systemctl status services-availability-dashboard-collector ; \
		$$SHELL '


# PHONYs
.PHONY: clean isort lint test local-dev-env
.PHONY: vue-dev-tools npm-install npm-lint npm-audit npm-build
.PHONY: webapp-setup webapp-settings webapp-config
.PHONY: daemon-start daemon-stop webapp-start webapp-stop
.PHONY: start stop


# Functions
define echo_title
	@echo ""
	@echo ""
	@echo "$$(tput bold)### $(1) ###$$(tput sgr0)"
	@echo ""
endef


# Self-documentated makefile (DO NOT EDIT PAST THIS LINE)
.DEFAULT_GOAL := show-help
.PHONY: show-help
show-help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) == Darwin && echo '--no-init --raw-control-chars')
