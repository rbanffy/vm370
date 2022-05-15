.PHONY: build start load
.DEFAULT_GOAL := help

SHELL = /bin/sh

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-10s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

help: ## Displays this message.
	@echo "Please use \`make <target>' where <target> is one of:"
	@python3 -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

build: ## Builds the Docker image
	docker build -t vm370 .

start: build ## Builds and starts the Docker image
	docker start -d -p 3270:3270 vm370

upload:
	docker image tag vm370 ${USER}/vm370:latest
	docker image push ${USER}/vm370:latest
