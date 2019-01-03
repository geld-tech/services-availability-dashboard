LOCAL_DEV_ENV=local-dev-env
NPM_DEV_ENV=local-dev-env/webapp

.PHONY:  clean clean-pyc isort lint test all

all: clean isort lint test local-dev-env vue-dev-tools npm-install npm-run-lint npm-audit npm-run-build
	@echo ""

help:
	@echo "Makefile targets:"
	@echo ""
	@echo "    clean"
	@echo "        Remove all local build artifacts"
	@echo ""
	@echo "    clean-pyc"
	@echo "        Remove python artifacts"
	@echo ""
	@echo "    isort"
	@echo "        Sort import statements"
	@echo ""
	@echo "    lint"
	@echo "        Check style with flake8"
	@echo ""
	@echo "    test"
	@echo "        Run unit tests"
	@echo ""
	@echo "    local-dev-env"
	@echo "        Prepare local development environment"
	@echo ""
	@echo "    all"
	@echo "        Run all targets locally"
	@echo ""

clean:
	@echo ""
	@echo "### LOCAL DEV ENV CLEANUP ###"
	rm -rf $(LOCAL_DEV_ENV)

clean-pyc:
	@echo ""
	@echo "### PYTHON FILES CLEANUP ###"
	find . -name '*.pyc' -exec rm --force {} +
	find . -name '*.pyo' -exec rm --force {} +

isort:
	@echo ""
	@echo "### PYTHON ISORT ###"
	sh -c "isort --skip-glob=.tox --recursive sources/server/ "
	sh -c "isort --skip-glob=.tox --recursive sources/server/modules/ "


# Flask application, enforce no syntax errors or undefined names, and flags other issues
lint:
	@echo ""
	@echo "### PYTHON FLAKE8 ###"
	@echo ""
	flake8 sources/server/ --show-source --max-line-length=239 --max-complexity=10 --statistics --count

test:
	@echo ""
	@echo "### PYTHON UNIT TESTS ###"
	@echo "XXX TODO"

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

# Build Vue application with DevTools enabled (Firefox or Chrome plugin)
vue-dev-tools:
	@echo ""
	@echo "### VUE DEVTOOLS ###"
	sed -i '/Vue.config.productionTip = false/a Vue.config.devtools = true' $(LOCAL_DEV_ENV)/webapp/src/main.js

npm-install:
	@echo "### NPM INSTALL ###"
	cd $(NPM_DEV_ENV) ; npm install

npm-run-lint: npm-install
	@echo ""
	@echo "### NPM LINT ###"
	cd $(NPM_DEV_ENV) ; npm run lint

npm-audit: npm-install
	@echo ""
	@echo "### NPM AUDIT ###"
	-cd $(NPM_DEV_ENV) ; npm audit 2> /dev/null # Run conditionally as not installed on all systems (ignore failures with -)

npm-run-build: npm-install
	@echo "### NPM BUILD ###"
	cd $(NPM_DEV_ENV) ; npm run build