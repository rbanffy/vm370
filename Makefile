.PHONY: help build upload upload_images
.DEFAULT_GOAL := help

SHELL = /bin/sh
BUILD_DIR = build

OPERATING_SYSTEM ?= vm370
ALL_ARCHES = amd64 armv6 armv7 arm64 s390x ppc64le
ARCH ?=
ARCHES = $(if $(ARCH),$(ARCH),$(ALL_ARCHES))
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
	@echo "Please use \`make <target>\` where <target> is one of:"
	@python3 -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

build: distribution ## Builds the Docker images (set ARCH to build a subset)
	@for arch in $(ARCHES); do \
		case $$arch in \
			amd64) platform=linux/amd64; base=debian:testing-slim ;; \
			armv6) platform=linux/arm/v6; base=tianon/raspbian:trixie-slim ;; \
			armv7) platform=linux/arm/v7; base=debian:testing-slim ;; \
			arm64) platform=linux/arm64; base=debian:testing-slim ;; \
			s390x) platform=linux/s390x; base=debian:testing-slim ;; \
			ppc64le) platform=linux/ppc64le; base=debian:testing-slim ;; \
			*) echo "Unknown ARCH: $$arch (expected one of: $(ALL_ARCHES))" >&2; exit 1 ;; \
		esac; \
		docker build -t ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-$$arch --platform=$$platform --build-arg BASE_IMAGE=$$base --file ./Dockerfile-${OPERATING_SYSTEM} --progress plain . || exit 1; \
	done

upload_images: ## Uploads the local docker images (set ARCH to upload a subset)
	@for arch in $(ARCHES); do \
		docker image push ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-$$arch || exit 1; \
	done

upload: upload_images ## Uploads the manifest (set ARCH to include a subset)
	@amends=""; \
	for arch in $(ARCHES); do \
		amends="$$amends --amend ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}-$$arch"; \
	done; \
	docker manifest create ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG} $$amends; \
	docker manifest push ${USER}/${OPERATING_SYSTEM}:${IMAGE_TAG}
