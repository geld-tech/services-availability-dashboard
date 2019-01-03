LOCAL_DEV_ENV=.local_dev

.PHONY:  clean clean-pyc isort lint test all

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


lint:
	@echo ""
	@echo "### PYTHON FLAKE8 ###" # Flask application, enforce no syntax errors or undefined names, and flags other issues
	@echo ""
	flake8 sources/server/ --show-source --max-line-length=239 --max-complexity=10 --statistics --count

test:
	@echo ""
	@echo "### PYTHON UNIT TESTS ###"
	@echo ""

all: clean isort lint test
	@echo ""
