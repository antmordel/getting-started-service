KIND            := kindest/node:v1.27.3
KIND_CLUSTER    := golang-service-cluster
SERVICE_NAME		:= golang-service
VERSION  		 		:= 0.0.1

DEPENDENCIES := brew kind kubectl kustomize pgcli vault kustomize

# ==================================================================================== #
# HELPERS
# ==================================================================================== #

## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

# ==================================================================================== #
# DEPENDENCIES
# ==================================================================================== #

## check-dependencies: check for required dependencies
.PHONY: check-dependencies
check-dependencies:
	@$(foreach dep,$(DEPENDENCIES), \
		which $(dep) > /dev/null || { echo "$(dep) is not installed. Please install $(dep)."; exit 1; }; \
	)

## install-dependencies: install required dependencies using brew
.PHONY: install-dependencies
install-dependencies:
	@$(foreach dep,$(DEPENDENCIES), \
		which $(dep) > /dev/null || brew install $(dep); \
	)

# ==================================================================================== #
# RUNNING DEV
# ==================================================================================== #

## run-local: run the application locally
.PHONY: run-local
run-local:
	@echo "🚀 Running application locally"
	@go run app/services/sales-api/main.go

## dev-up: start the development environment using Kind
.PHONY: dev-up
dev-up:
	kind create cluster \
		--image $(KIND) \
		--name $(KIND_CLUSTER)

	kubectl wait --timeout=120s --namespace=local-path-storage --for=condition=Available deployment/local-path-provisioner

## dev-load: loads the image into the kind cluster
.PHONY: dev-load
dev-load:
	@echo "🚀 Loading 'golang-service' image into Kind cluster"
	@kind load docker-image $(SERVICE_NAME):$(VERSION) --name $(KIND_CLUSTER)

## dev-apply: apply kustomization and applies the artifacts to the cluster in local dev
.PHONY: dev-apply
dev-apply:
	@echo "🚀 Applying kustomization to Kind cluster"
	@kustomize build zarf/k8s/dev/sales | kubectl apply -f -

# ==================================================================================== #
# BUILDING
# ==================================================================================== #

## build-service: build the service Docker image
.PHONY: build-service
build-service:
	@echo "🚀 Building service Docker image"
	@docker build \
		-f zarf/docker/Dockerfile.service \
		-t $(SERVICE_NAME):$(VERSION) \
		.
