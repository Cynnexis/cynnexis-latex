# Makefile based on https://gist.github.com/mpneuried/0594963ad38e68917ef189b4e6a269db
DOCKER_IMAGE=cynnexis/latex

all: build

clear:
	docker rmi -f $$(docker images -f "reference=$(DOCKER_IMAGE)" -q)

build:
	docker build -t $(DOCKER_IMAGE) .

build-nc:
	docker build --no-cache -t $(DOCKER_IMAGE) .

run:
	docker run --rm -it $(DOCKER_IMAGE) bash

stop:
	docker stop $(DOCKER_IMAGE); docker rm $(DOCKER_IMAGE)