REGISTRY_OWNER:=fazenda
MULTIARCH:=true
ARCHS:=linux/amd64
PROJECT:=hugo
PROJECT_TAG:=latest

ifeq (true, $(MULTIARCH))
	ARCHS:=linux/amd64,linux/arm64/v8,linux/arm/v7,linux/arm/v6
endif

all: install setup

install:
	@curl -fSL https://get.docker.com | sh
	@sudo usermod -aG docker $USER
	@sudo systemctl enable docker
	@sudo systemctl start docker

# https://github.com/docker/buildx/issues/132#issuecomment-847136842
setup:
	@LATEST=$(shell wget -qO- "https://api.github.com/repos/docker/buildx/releases/latest" | jq -r .name); \
		wget https://github.com/docker/buildx/releases/download/$$LATEST/buildx-$$LATEST.linux-amd64; \
		chmod a+x buildx-$$LATEST.linux-amd64; \
		mkdir -p ~/.docker/cli-plugins; \
		mv buildx-$$LATEST.linux-amd64 ${HOME}/.docker/cli-plugins/docker-buildx;

build:
	@docker buildx build --platform $(ARCHS) --push --tag ${REGISTRY_OWNER}/${PROJECT}:${PROJECT_TAG} .

test:
	@docker-compose --file=docker-compose.test.yml up --build