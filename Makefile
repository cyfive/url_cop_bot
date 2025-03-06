.PHONY:	prepare build publish clean

PULL_DOCKER_REPO ?= docker.io
PUSH_DOCKER_REPO ?= please-set-registry
DOCKER_REPO_USER ?= please-set-user-name
DOCKER_REPO_PASS ?= please-set-password

VERSION ?= 1.0.0

prepare:
	echo ${DOCKER_REPO_PASS} | podman login ${PUSH_DOCKER_REPO} -u ${DOCKER_REPO_USER} --password-stdin

build:
	podman build --network host . \
		-t ${PUSH_DOCKER_REPO}/url-cop-bot:${VERSION} \
		-t ${PUSH_DOCKER_REPO}/url-cop-bot:latest \
		--build-arg DOCKER_REPO=${PULL_DOCKER_REPO}

publish: prepare
	podman push ${PUSH_DOCKER_REPO}/url-cop-bot:${VERSION}
	podman push ${PUSH_DOCKER_REPO}/url-cop-bot:latest

clean:
	podman image rm ${PUSH_DOCKER_REPO}/redis-benchmark:${VERSION}
	podman image rm ${PUSH_DOCKER_REPO}/redis-benchmark:latest
