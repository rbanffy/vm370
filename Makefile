.PHONY: help build start upload upload_images
.DEFAULT_GOAL := help

SHELL = /bin/sh

BRANCH = $(shell git branch --show-current)

ifeq ($(BRANCH),main)
	IMAGE_TAG = stable
else ifeq ($(BRANCH),develop)
	IMAGE_TAG = latest
else
	IMAGE_TAG = $(BRANCH)
endif

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
	docker build -t ${USER}/vm370:${IMAGE_TAG}-amd64 --platform=linux/amd64 .
	docker build -t ${USER}/vm370:${IMAGE_TAG}-arm64 --platform=linux/arm64 .
	docker build -t ${USER}/vm370:${IMAGE_TAG}-armv6 --platform=linux/arm/v6 .
	docker build -t ${USER}/vm370:${IMAGE_TAG}-armv7 --platform=linux/arm/v7 .
	docker build -t ${USER}/vm370:${IMAGE_TAG}-i386 --platform=linux/i386 .
	docker build -t ${USER}/vm370:${IMAGE_TAG}-mips64le --platform=linux/mips64le .
	docker build -t ${USER}/vm370:${IMAGE_TAG}-ppc64le --platform=linux/ppc64le .
	docker build -t ${USER}/vm370:${IMAGE_TAG}-s390x --platform=linux/s390x .

upload_images: ## Uploads the docker images
	docker image push ${USER}/vm370:${IMAGE_TAG}-amd64
	docker image push ${USER}/vm370:${IMAGE_TAG}-arm64
	docker image push ${USER}/vm370:${IMAGE_TAG}-armv6
	docker image push ${USER}/vm370:${IMAGE_TAG}-armv7
	docker image push ${USER}/vm370:${IMAGE_TAG}-i386
	docker image push ${USER}/vm370:${IMAGE_TAG}-mips64le
	docker image push ${USER}/vm370:${IMAGE_TAG}-ppc64le
	docker image push ${USER}/vm370:${IMAGE_TAG}-s390x

upload: upload_images ## Uploads the manifest
	docker manifest create ${USER}/vm370:${IMAGE_TAG} \
		--amend ${USER}/vm370:${IMAGE_TAG}-amd64 \
		--amend ${USER}/vm370:${IMAGE_TAG}-amd64 \
		--amend ${USER}/vm370:${IMAGE_TAG}-armv6 \
		--amend ${USER}/vm370:${IMAGE_TAG}-armv7 \
		--amend ${USER}/vm370:${IMAGE_TAG}-i386 \
		--amend ${USER}/vm370:${IMAGE_TAG}-mips64le \
		--amend ${USER}/vm370:${IMAGE_TAG}-ppc64le
		--amend ${USER}/vm370:${IMAGE_TAG}-s390x \
	docker manifest push ${USER}/vm370:${IMAGE_TAG}
