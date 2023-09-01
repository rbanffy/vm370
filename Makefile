.PHONY: help build start upload upload_images
.DEFAULT_GOAL := help

SHELL = /bin/sh

OPERATING_SYSTEM = vm370

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

help: ## Displays this message.
	@echo "Please use \`make <target>' where <target> is one of:"
	@python3 -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

build: ## Builds the Docker images
	docker build -t ${USER}/${OPERATING_SYSTEM}:latest-amd64 --platform=linux/amd64 --file Dockerfile-${OPERATING_SYSTEM} .
	docker build -t ${USER}/${OPERATING_SYSTEM}:latest-arm64 --platform=linux/arm64 --file ./Dockerfile-${OPERATING_SYSTEM} .
	docker build -t ${USER}/${OPERATING_SYSTEM}:latest-armv6 --platform=linux/arm/v6 --file ./Dockerfile-${OPERATING_SYSTEM} .
	docker build -t ${USER}/${OPERATING_SYSTEM}:latest-armv7 --platform=linux/arm/v7 --file ./Dockerfile-${OPERATING_SYSTEM} .
	docker build -t ${USER}/${OPERATING_SYSTEM}:latest-s390x --platform=linux/s390x --file ./Dockerfile-${OPERATING_SYSTEM} . 
	docker build -t ${USER}/${OPERATING_SYSTEM}:latest-ppc64le --platform=linux/ppc64le --file ./Dockerfile-${OPERATING_SYSTEM} .

start: build ## Builds and starts the local arch Docker image
	docker start -d -p 3270:3270 vm370

upload_images: ## Uploads the docker images
	docker image push ${USER}/${OPERATING_SYSTEM}:latest-amd64
	docker image push ${USER}/${OPERATING_SYSTEM}:latest-arm64
	docker image push ${USER}/${OPERATING_SYSTEM}:latest-armv6
	docker image push ${USER}/${OPERATING_SYSTEM}:latest-armv7
	docker image push ${USER}/${OPERATING_SYSTEM}:latest-s390x
	docker image push ${USER}/${OPERATING_SYSTEM}:latest-ppc64le

upload: upload_images ## Uploads the manifest
	docker manifest create ${USER}/${OPERATING_SYSTEM}:latest \
		--amend ${USER}/${OPERATING_SYSTEM}:latest-amd64 \
		--amend ${USER}/${OPERATING_SYSTEM}:latest-amd64 \
		--amend ${USER}/${OPERATING_SYSTEM}:latest-armv6 \
		--amend ${USER}/${OPERATING_SYSTEM}:latest-armv7 \
		--amend ${USER}/${OPERATING_SYSTEM}:latest-s390x \
		--amend ${USER}/${OPERATING_SYSTEM}:latest-ppc64le
	docker manifest push ${USER}/${OPERATING_SYSTEM}:latest
