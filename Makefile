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

DEPENDENCIES := brew kind kubectl kustomize pgcli vault 

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

KIND            := kindest/node:v1.27.3
KIND_CLUSTER    := golang-service-cluster

## dev-up: start the development environment using Kind
.PHONY: dev-up
dev-up:
	kind create cluster \
		--image $(KIND) \
		--name $(KIND_CLUSTER)

	kubectl wait --timeout=120s --namespace=local-path-storage --for=condition=Available deployment/local-path-provisioner
