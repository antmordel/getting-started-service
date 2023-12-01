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
