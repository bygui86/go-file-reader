
# VARIABLES
## general
CONTAINER_REGISTRY_PREFIX = bygui86/
CONTAINER_NAME = go-file-reader
CONTAINER_TAG = v1.0.0
## global
export GO111MODULE = on


# CONFIG
.PHONY: help print-variables
.DEFAULT_GOAL = help


# ACTIONS

## application

mod-tidy :		## Tidy go modules references
	go mod tidy

mod-down : mod-tidy		## Download go modules references
	go mod download

build : mod-down		## Build application
	go build

test : build		## Run tests
	go test -coverprofile=coverage.out -count=5 -race ./...

run : build		## Run application
	go run main.go

## cointaier

container-build :		## Build container image
	docker build . -t $(CONTAINER_REGISTRY_PREFIX)$(CONTAINER_NAME):$(CONTAINER_TAG)

container-run :		## Push container image to Container Registry
	docker run -ti --rm --name $(CONTAINER_NAME) \
		$(CONTAINER_REGISTRY_PREFIX)$(CONTAINER_NAME):$(CONTAINER_TAG)

container-push :		## Push container image to Container Registry
	docker push $(CONTAINER_REGISTRY_PREFIX)$(CONTAINER_NAME):$(CONTAINER_TAG)

## helpers

help :		## Help
	@echo ""
	@echo "*** \033[33mMakefile help\033[0m ***"
	@echo ""
	@echo "Targets list:"
	@grep -E '^[a-zA-Z_-]+ :.*?## .*$$' $(MAKEFILE_LIST) | sort -k 1,1 | awk 'BEGIN {FS = ":.*?## "}; {printf "\t\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ""

print-variables :		## Print variables values
	@echo ""
	@echo "*** \033[33mMakefile variables\033[0m ***"
	@echo ""
	@echo "- - - makefile - - -"
	@echo "MAKE: $(MAKE)"
	@echo "MAKEFILES: $(MAKEFILES)"
	@echo "MAKEFILE_LIST: $(MAKEFILE_LIST)"
	@echo "- - -"
	@echo "NAME: $(NAME)"
	@echo "- - -"
	@echo "CONTAINER_NAME: $(CONTAINER_NAME)"
	@echo "CONTAINER_VERSION: $(CONTAINER_VERSION)"
	@echo "REGISTRY_PREFIX: $(REGISTRY_PREFIX)"
	@echo "CONTAINER_TAG: $(CONTAINER_TAG)"
	@echo ""
