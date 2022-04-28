# Makefile based on https://gist.github.com/mpneuried/0594963ad38e68917ef189b4e6a269db
SHELL := /bin/bash
DOCKER_IMAGE=cynnexis/latex
ifneq (,$(wildcard ./.env))
	include .env
	export $(shell sed 's/=.*//' .env)
endif
.ONESHELL:

help:
	@echo "Makefile for cynnexis/latex"
	echo
	echo "usage: $(MAKE) COMMAND"
	echo "with COMMAND being one of the following keyword:"
	echo ''
	echo "  clean     - Remove the Docker image."
	echo "  clean-all - Remove the Docker image and the dangling image (intermediate layers)."
	echo "              Warning: this operation remove ALL dangling images, not just the one regarding this specific image."
	echo "  build     - Build the Docker image. The log file can be found at build/build.log."
	echo "              CTAN_MIRROR: The URL to the CTAN mirror."
	echo "              DEBUG: If 'true', the Docker image will install a light version of TeX Live, for debugging purposes."
	echo "  run-it    - Run the Docker image in interactive mode, using bash as en entry-point."
	echo "  *.pdf     - Run the Docker image to generate the given argument '*.pdf'. The file '*.tex' must exist in the working directory."
	echo "  version   - Print the current version of the project. To only display the version number, use the command 'short-version'."
	echo

.PHONY: clean
clean:
	docker rmi -f $(DOCKER_IMAGE)

.PHONY: clean-all
clean-all: clean
	docker rmi -f $$(docker images -f "dangling=true" -q) || true

texlive.profile: config/texlive.debug.profile config/texlive.prod.profile
	@set -euo pipefail
	if [[ "$(DEBUG)" == "true" ]]; then
		cp config/texlive.debug.profile texlive.profile
	else
		cp config/texlive.prod.profile texlive.profile
	fi

build/build.log: Dockerfile install-texlive.sh texlive.profile VERSION
	@set -euo pipefail

	# Trap exit signal to clean up
	trap 'rm -f texlive.profile' EXIT

	# Create the build directory
	mkdir -p build

	# Get project version
	PROJECT_VERSION="$$($(MAKE) --no-print-directory short-version)"

	time docker build -t "$(DOCKER_IMAGE):latest" -f "$<" . --build-arg=PROJECT_VERSION="$$PROJECT_VERSION" --build-arg APT_UBUNTU_MIRROR --build-arg CTAN_MIRROR --build-arg DEBUG="$(DEBUG)" --progress=plain |& tee "$@"

	# Remove TeXLive profile (and reset trap)
	rm texlive.profile
	trap - EXIT

	# Tag images
	docker tag "$(DOCKER_IMAGE):latest" "$(DOCKER_IMAGE):$$PROJECT_VERSION"

	if [[ "$(DEBUG)" == "true" ]]; then
		docker tag "$(DOCKER_IMAGE):latest" "$(DOCKER_IMAGE):debug"
	fi

.PHONY: build
build: build/build.log

.PHONY: run-it
run-it:
	docker run --rm -it $(DOCKER_IMAGE) bash

.PHONY: test
test:
	cd test/ && $(SHELL) test.sh

%.pdf: %.tex
	@set -euo pipefail

	# Search for docker image
	if ! docker images '--format={{ .Repository }}' | grep -qe "$(DOCKER_IMAGE)"; then
		# Build the image
		echo "Docker image $(DOCKER_IMAGE) was not found. Building it..."
		$(MAKE) --no-print-directory build
	fi

	PS4='$$ '
	set -x

	docker run --rm --name compile-latex-document -v "$$(pwd):/root/latex" "$(DOCKER_IMAGE)" pdflatex -shell-escape -halt-on-error -file-line-error -output-directory "/root/latex/$(dir $<)" "/root/latex/$<"

	{ set +x } 2> /dev/null

.PHONY: short-version
short-version: VERSION
	@set -euo pipefail
	cat VERSION | head -n1 | xargs

.PHONY: version
version: VERSION
	@set -euo pipefail
	echo "cynnexis-latex version $$($(MAKE) --no-print-directory short-version)"
