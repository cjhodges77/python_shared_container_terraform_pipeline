PYTHON_VERSION = "3.9"
REGISTRY = ************.dkr.ecr.eu-west-2.amazonaws.com
TAG ?= latest

DEV_IMAGE_URI = $(REGISTRY)/aws-lambda-dev-base:$(TAG)
RELEASE_IMAGE_URI = $(REGISTRY)/aws-lambda-release-base:$(TAG)

build-dev-base: build-release-base
	docker build -t $(DEV_IMAGE_URI) images/aws-lambda-python-dev-base

build-release-base:
	docker build --build-arg PYTHON_VERSION=$(PYTHON_VERSION) -t $(RELEASE_IMAGE_URI) \
		images/aws-lambda-python-release-base

buildx-clean:
	docker run --privileged --rm tonistiigi/binfmt --uninstall arm64
	docker buildx rm $(JOB_NAME)

buildx-prepare:
	docker run --privileged --rm tonistiigi/binfmt --install arm64
	docker buildx create --name $(JOB_NAME) || exit 0
	docker buildx use $(JOB_NAME)

buildx-build-dev-base:
	docker buildx build -t $(DEV_IMAGE_URI) \
		--platform linux/arm64,linux/amd64 images/aws-lambda-python-dev-base

buildx-build-release-base:
	docker buildx build --build-arg PYTHON_VERSION=$(PYTHON_VERSION) -t $(RELEASE_IMAGE_URI) \
		--platform linux/arm64,linux/amd64 images/aws-lambda-python-release-base

buildx-push-dev-base:
	docker buildx build -t $(DEV_IMAGE_URI) \
	  	--push \
		--platform linux/arm64,linux/amd64 images/aws-lambda-python-dev-base

buildx-push-release-base:
	docker buildx build --build-arg PYTHON_VERSION=$(PYTHON_VERSION) -t $(RELEASE_IMAGE_URI) \
		--push \
		--platform linux/arm64,linux/amd64 images/aws-lambda-python-release-base

test-dev-base: build-dev-base
	docker run --rm -w /devtools --entrypoint make -v "$(PWD)/example-project:/var/task" $(DEV_IMAGE_URI) lint
