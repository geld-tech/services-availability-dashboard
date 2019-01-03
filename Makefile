LOCAL_DEV_ENV=.local_dev

.PHONY:  clean clean-pyc isort lint build test local-run

help:
	@echo "Makefile targets:"
	@echo ""
	@echo "    clean"
	@echo "        Remove all local build artifacts."
	@echo ""
	@echo "    clean-pyc"
	@echo "        Remove python artifacts."
	@echo ""
	@echo "    isort"
	@echo "        Sort import statements."
	@echo ""
	@echo "    lint"
	@echo "        Check style with flake8."
	@echo ""
	@echo "    test"
	@echo "        Run unit tests"
	@echo ""
	@echo "    local-run"
	@echo "        Run the project onlocal machine."
	@echo ""

clean:
	rm -rf $(LOCAL_DEV_ENV)

clean-pyc:
	find . -name '*.pyc' -exec rm --force {} +
	find . -name '*.pyo' -exec rm --force {} +

isort:
	sh -c "isort --skip-glob=.tox --recursive sources/server/ "
	sh -c "isort --skip-glob=.tox --recursive sources/server/modules/ "
