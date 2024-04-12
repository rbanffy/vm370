.PHONY: help build upload upload_images
.DEFAULT_GOAL := help

SHELL = /bin/sh
BUILD_DIR = build

OPERATING_SYSTEM ?= vm370
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

ifeq ($(OPERATING_SYSTEM),mvstk5)
distribution: ## Downloads local distribution files
	@echo "Dowloading distribution files"
	wget --no-check-certificate -c --directory-prefix ${BUILD_DIR} https://www.prince-webdesign.nl/images/downloads/mvs-tk5.zip
	wget --no-check-certificate -c --directory-prefix ${BUILD_DIR} https://www.prince-webdesign.nl/images/downloads/srccbt_catlg.txt
	wget --no-check-certificate -c --directory-prefix ${BUILD_DIR} https://www.prince-webdesign.nl/images/downloads/srccbt.zip
	@echo "Decompressing distribution files"
	unzip -o ${BUILD_DIR}/mvs-tk5.zip -d ${BUILD_DIR}
	unzip -o ${BUILD_DIR}/srccbt.zip -d ${BUILD_DIR}/mvs-tk5
else
distribution:
	@echo "Distribution will be downloaded by docker."
endif

help: ## Displays this message.
	@echo "Please use \`make <target>' where <target> is one of:"
	@python3 -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

build: distribution ## Builds the Docker images
	docker build -t ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-amd64 --platform=linux/amd64 --file Dockerfile-${OPERATING_SYSTEM} .
	docker build -t ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-arm64 --platform=linux/arm64 --file ./Dockerfile-${OPERATING_SYSTEM} .
	docker build -t ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-armv6 --platform=linux/arm/v6 --file ./Dockerfile-${OPERATING_SYSTEM} .
	docker build -t ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-armv7 --platform=linux/arm/v7 --file ./Dockerfile-${OPERATING_SYSTEM} .
	docker build -t ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-s390x --platform=linux/s390x --file ./Dockerfile-${OPERATING_SYSTEM} .
	docker build -t ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-ppc64le --platform=linux/ppc64le --file ./Dockerfile-${OPERATING_SYSTEM} .

upload_images: ## Uploads the local docker images
	docker image push ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-amd64
	docker image push ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-arm64
	docker image push ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-armv6
	docker image push ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-armv7
	docker image push ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-s390x
	docker image push ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-ppc64le

upload: upload_images ## Uploads the manifest
	docker manifest create ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG} \
		--amend ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-amd64 \
		--amend ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-amd64 \
		--amend ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-armv6 \
		--amend ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-armv7 \
		--amend ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-s390x \
		--amend ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-ppc64le
	docker manifest push ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}
