.PHONY: help build start upload upload_images
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

build: ## Builds the Docker images
	docker build -t ${USER}/vm370:latest-amd64 --platform=linux/amd64 .
	docker build -t ${USER}/vm370:latest-arm64 --platform=linux/arm64 .
	docker build -t ${USER}/vm370:latest-armv6 --platform=linux/arm/v6 .
	docker build -t ${USER}/vm370:latest-armv7 --platform=linux/arm/v7 .
	docker build -t ${USER}/vm370:latest-s390x --platform=linux/s390x .
	docker build -t ${USER}/vm370:latest-ppc64le --platform=linux/ppc64le .

start: build ## Builds and starts the Docker image
	docker start -d -p 3270:3270 vm370

upload_images: ## Uploads the docker images
	docker image push ${USER}/vm370:latest-amd64
	docker image push ${USER}/vm370:latest-arm64
	docker image push ${USER}/vm370:latest-armv6
	docker image push ${USER}/vm370:latest-armv7
	docker image push ${USER}/vm370:latest-s390x
	docker image push ${USER}/vm370:latest-ppc64le

upload: upload_images ## Uploads the manifest
	docker manifest create ${USER}/vm370:latest \
		--amend ${USER}/vm370:latest-amd64 \
		--amend ${USER}/vm370:latest-amd64 \
		--amend ${USER}/vm370:latest-armv6 \
		--amend ${USER}/vm370:latest-armv7 \
		--amend ${USER}/vm370:latest-s390x \
		--amend ${USER}/vm370:latest-ppc64le
	docker manifest push ${USER}/vm370:latest
