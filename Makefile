LOCAL_DEV_ENV=local-dev-env
SRV_DEV_ENV=local-dev-env/server
NPM_DEV_ENV=local-dev-env/webapp

.PHONY: clean isort lint test local-dev-env vue-dev-tools npm-install npm-run-lint npm-audit npm-run-build setup-app create-stub-config

## Run all targets locally
all: clean isort lint test local-dev-env vue-dev-tools npm-install npm-run-lint npm-audit npm-run-build setup-app create-stub-config
	@echo ""
	@echo "Build completed successfully!"

## Remove all local build artifacts
clean:
	@echo ""
	@echo "### LOCAL DEV ENV CLEANUP ###"
	rm -rf $(LOCAL_DEV_ENV)

## Remove python artifacts
clean-pyc:
	@echo ""
	@echo "### PYTHON FILES CLEANUP ###"
	find . -name '*.pyc' -exec rm --force {} +
	find . -name '*.pyo' -exec rm --force {} +

## Sort Python import statements
isort:
	@echo ""
	@echo "### PYTHON ISORT ###"
	sh -c "isort --skip-glob=.tox --recursive sources/server/ "
	sh -c "isort --skip-glob=.tox --recursive sources/server/modules/ "


## Check coding style of Flask application, enforce no syntax errors or undefined names, and flags other issues
lint:
	@echo ""
	@echo "### PYTHON FLAKE8 ###"
	@echo ""
	flake8 sources/server/ --show-source --max-line-length=239 --max-complexity=10 --statistics --count

## Run unit tests
test:
	@echo ""
	@echo "### PYTHON UNIT TESTS ###"
	@echo "XXX TODO"

## Prepare local development environment
local-dev-env:
	@echo ""
	@echo "### LOCAL DEV ENV ###"
	@echo "== Prepare folders =="
	mkdir -p $(LOCAL_DEV_ENV)
	cp -r sources/server/ $(LOCAL_DEV_ENV)
	cp -r sources/webapp/ $(LOCAL_DEV_ENV)
	@echo "== Replace place holders =="
	find $(LOCAL_DEV_ENV) -type f | xargs sed -i "s/localdev/localdev/g"
	find $(LOCAL_DEV_ENV) -type f | xargs sed -i "s/Running application locally/Running application locally/g"
	find $(LOCAL_DEV_ENV) -type f | xargs sed -i "s/geld.tech/geld.tech/g"
	find $(LOCAL_DEV_ENV) -type f | xargs sed -i "s/0.0.1/0.0.1/g"
	find $(LOCAL_DEV_ENV) -type f | xargs sed -i "s/01-01-1970/01-01-1970/g"

## Ensure Vue application is built with DevTools enabled (requires Firefox or Chrome plugin)
vue-dev-tools:
	@echo ""
	@echo "### VUE DEVTOOLS ###"
	sed -i '/Vue.config.productionTip = false/a Vue.config.devtools = true' $(LOCAL_DEV_ENV)/webapp/src/main.js

## Install NPM Modules in local dev environment
npm-install:
	@echo "### NPM INSTALL ###"
	cd $(NPM_DEV_ENV) ; npm install

## Runs linter on Vue web application files
npm-run-lint: npm-install
	@echo ""
	@echo "### NPM LINT ###"
	cd $(NPM_DEV_ENV) ; npm run lint

## Runs NPM audit to flag security issues
npm-audit: npm-install
	@echo ""
	@echo "### NPM AUDIT ###"
	-cd $(NPM_DEV_ENV) ; npm audit 2> /dev/null # Run conditionally as not installed on all systems (ignore failures with -)

## Runs a full build using NPM
npm-run-build: npm-install
	@echo "### NPM BUILD ###"
	cd $(NPM_DEV_ENV) ; npm run build

## Prepare application
setup-app: npm-run-build
	@echo ""
	@echo "### PREPARE ###"
	mkdir $(SRV_DEV_ENV)/templates/
	mkdir $(SRV_DEV_ENV)/static/
	cp $(NPM_DEV_ENV)/dist/*.html $(SRV_DEV_ENV)/templates/
	cp -r $(NPM_DEV_ENV)/dist/static/* $(SRV_DEV_ENV)/static/

## Create a stub settings.cfg file
create-stub-config:
	@echo ""
	@echo "### CREATE STUB SETTINGS ###"
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
	@echo ""
	@echo "### SETUP STUB SETTINGS ###"
	cp -f $(SRV_DEV_ENV)/config/settings.cfg.dev $(SRV_DEV_ENV)/config/settings.cfg

# # Run background metrics collector
# echo ""
# echo "### METRICS COLLECTOR ###"
# trap hupexit HUP
# trap intexit INT
# python monitor-collectord.py start debug
# sleep 5
#
#
# # Run application locally on port :5000 (Press CTRL+C to quit)
# echo ""
# echo "### RUN ###"
# python application.py
#

# Self-documentated make file
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
