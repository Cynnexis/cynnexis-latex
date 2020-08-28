# Makefile based on https://gist.github.com/mpneuried/0594963ad38e68917ef189b4e6a269db
SHELL := /bin/bash
DOCKER_IMAGE=cynnexis/latex

.PHONY: help clear build build-nc run-it

help:
	@echo "Makefile for cynnexis/latex"
	@echo ''
	@echo "Usage:"
	@echo ''
	@echo "  $(MAKE) COMMAND"
	@echo "with COMMAND being one of the following keyword:"
	@echo ''
	@echo "  clean     - Remove the Docker image."
	@echo "  clean-all - Remove the Docker image and the dangling image (intermediate layers)."
	@echo "              Warning: this operation remove ALL dangling images, not just the one regarding this specific image."
	@echo "  build     - Build the Docker image."
	@echo "              CTAN_MIRROR: The URL to the CTAN mirror."
	@echo "              DEBUG: If 'true', the Docker image will install a light version of TeX Live, for debugging purposes."
	@echo "  run-it    - Run the Docker image in interactive mode, using bash as en entry-point."
	@echo ''

clean:
	docker rmi -f $(DOCKER_IMAGE)

clean-all: clean
	docker rmi -f $$(docker images -f "dangling=true" -q) || true

build:
	if [[ "$(DEBUG)" == "true" ]]; then \
		cp config/texlive.debug.profile texlive.profile; \
	else \
		cp config/texlive.prod.profile texlive.profile; \
	fi; \
	docker build -t $(DOCKER_IMAGE) . --build-arg CTAN_MIRROR="$(CTAN_MIRROR)" --build-arg DEBUG="$(DEBUG)"; \
	rm texlive.profile

run-it:
	docker run --rm -it $(DOCKER_IMAGE) bash
