LOCAL_DEV_ENV=local-dev-env
SRV_DEV_ENV=local-dev-env/server
NPM_DEV_ENV=local-dev-env/webapp

## Run all targets locally
all: clean isort lint test local-dev-env vue-dev-tools npm-install npm-run-lint npm-audit npm-run-build setup-app create-stub-config
	@echo ""
	@echo "Build completed successfully!"

## Remove all local build artifacts
clean:
	$(call echo_title, "LOCAL DEV ENV CLEANUP")
	rm -rf $(LOCAL_DEV_ENV)

## Remove python artifacts
clean-pyc:
	$(call echo_title, "PYTHON FILES CLEANUP")
	find . -name '*.pyc' -exec rm --force {} +
	find . -name '*.pyo' -exec rm --force {} +

## Sort Python import statements
isort:
	$(call echo_title, "PYTHON FILES CLEANUP")
	sh -c "isort --skip-glob=.tox --recursive sources/server/ "
	sh -c "isort --skip-glob=.tox --recursive sources/server/modules/ "


## Check coding style of Flask application, enforce no syntax errors or undefined names, and flags other issues
lint:
	$(call echo_title, "PYTHON FILES CLEANUP")
	@echo ""
	flake8 sources/server/ --show-source --max-line-length=239 --max-complexity=10 --statistics --count

## Run unit tests
test:
	$(call echo_title, "PYTHON UNIT TESTS")
	@echo "XXX TODO"

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

## Ensure Vue application is built with DevTools enabled (requires Firefox or Chrome plugin)
vue-dev-tools:
	$(call echo_title, "VUE DEVTOOLS")
	sed -i '/Vue.config.productionTip = false/a Vue.config.devtools = true' $(LOCAL_DEV_ENV)/webapp/src/main.js

## Install NPM Modules in local dev environment
npm-install:
	$(call echo_title, "NPM INSTALL")
	cd $(NPM_DEV_ENV) ; npm install

## Runs linter on Vue web application files
npm-run-lint: npm-install
	$(call echo_title, "NPM LINT")
	cd $(NPM_DEV_ENV) ; npm run lint

## Runs NPM audit to flag security issues
npm-audit: npm-install
	$(call echo_title, "NPM AUDIT")
	-cd $(NPM_DEV_ENV) ; npm audit 2> /dev/null # Run conditionally as not installed on all systems (ignore failures with -)

## Runs a full build using NPM
npm-run-build: npm-install
	$(call echo_title, "NPM BUILD")
	cd $(NPM_DEV_ENV) ; npm run build

## Prepare application
setup-app: npm-run-build
	$(call echo_title, "PREPARE")
	mkdir $(SRV_DEV_ENV)/templates/
	mkdir $(SRV_DEV_ENV)/static/
	cp $(NPM_DEV_ENV)/dist/*.html $(SRV_DEV_ENV)/templates/
	cp -r $(NPM_DEV_ENV)/dist/static/* $(SRV_DEV_ENV)/static/

## Create a stub settings.cfg file
create-stub-config:
	$(call echo_title, "CREATE STUB SETTINGS")
	@touch $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "[admin]" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "password = Y25mZmpiZXE=" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "[ganalytics]" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "ua_id = 1234567" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "[services]" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "geld.tech = https://geld.tech" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "wikipedia = https://en.wikipedia.org" >> $(SRV_DEV_ENV)/config/settings.cfg.dev
	@echo "yahoo.co.jp = https://www.yahoo.co.jp" >> $(SRV_DEV_ENV)/config/settings.cfg.dev

## Configure stub settings.cfg
setup-stub-config:
	$(call echo_title, "SETUP STUB SETTINGS")
	cp -f $(SRV_DEV_ENV)/config/settings.cfg.dev $(SRV_DEV_ENV)/config/settings.cfg

## Start metrics collector daemon
start-metrics-daemon:
	$(call echo_title, "START METRICS DAEMON")
	@echo ""
	@echo "Starting stub background daemon locally, use 'make stop-metrics-daemon' to terminate.."
	@echo ""
	python $(SRV_DEV_ENV)/monitor-collectord.py start debug
	sleep 3

## Stop metrics collector daemon
stop-metrics-daemon:
	$(call echo_title, "STOP METRICS DAEMON")
	-python $(SRV_DEV_ENV)/monitor-collectord.py stop
	-pkill -f $(SRV_DEV_ENV)/monitor-collectord.py

## Start web application
start-webapp:
	$(call echo_title, "START WEB APPLICATION")
	@echo ""
	@echo "Starting web application locally, use 'make stop-webapp' to terminate.."
	@echo ""
	python $(SRV_DEV_ENV)/application.py &

## Stop web application
stop-webapp:
	$(call echo_title, "STOP WEB APPLICATION")
	-pkill -f $(SRV_DEV_ENV)/application.py

## Start local development environment
start-local-dev: all start-metrics-daemon start-webapp

## Stop local development environment
stop-local-dev: stop-metrics-daemon stop-webapp


# PHONYs
.PHONY: clean isort lint test local-dev-env
.PHONY: vue-dev-tools npm-install npm-run-lint npm-audit npm-run-build setup-app create-stub-config
.PHONY: setup-app create-stub-config setup-stub-config
.PHONY: start-metrics-daemon stop-metrics-daemon start-webapp stop-webapp

# Functions
define echo_title
	@echo ""
	@echo "$$(tput bold)### $(1) ###$$(tput sgr0)"
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
