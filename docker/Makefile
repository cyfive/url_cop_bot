
SHELL = /bin/bash
NAME = url-bot
DOCKERFILE = Dockerfile
DOCKER_REPO = docker.io/cyfive


.PHONY: build force test debug

build:
	podman build -f "${DOCKERFILE}" -t "${DOCKER_REPO}/${NAME}" .

force:
	podman build -f "${DOCKERFILE}" -t "${DOCKER_REPO}/${NAME}" --no-cache .

test:
	$(MAKE)
	podman run -it $(NAME):latest

debug:	test
	podman run -it --user=root --entrypoint ${SHELL} $(NAME):latest
