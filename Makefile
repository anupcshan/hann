## Variables
REPO := github.com/habedi/hann
COVER_PROFILE := coverage.txt
GO_FILES := $(shell find . -type f -name '*.go')
GO ?= go
ECHO := @echo
DATA_DIR := "example/data"
EXAMPLES_DIR := "example/cmd"
HF_DATASET := "nearest-neighbors-datasets"
HANN_SEED := 33
HANN_LOG := 1
HANN_BENCH_NTRD := 6

# List of packages to test (excluding example/cmd)
PACKAGES := $(shell $(GO) list ./... | grep -v $(EXAMPLES_DIR))

# Adjust PATH if necessary (append /snap/bin if not present)
PATH := $(if $(findstring /snap/bin,$(PATH)),$(PATH),/snap/bin:$(PATH))

####################################################################################################
## Shell Settings
####################################################################################################
SHELL := /bin/bash
.SHELLFLAGS := -e -o pipefail -c

####################################################################################################
## Go Targets
####################################################################################################

# Default target
.DEFAULT_GOAL := help

.PHONY: help
help: ## Show the help message for each target (command)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; \
 	{printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: format
format: ## Format Go files
	$(ECHO) "Formatting Go files..."
	@$(GO) fmt ./...

.PHONY: test
test: format ## Run the tests
	$(ECHO) "Running the tests..."
	@HANN_LOG=$(HANN_LOG) $(GO) test -v --cover --coverprofile=$(COVER_PROFILE) --race --count=1 ${PACKAGES}

.PHONY: showcov
showcov: test ## Display test coverage report
	$(ECHO) "Displaying test coverage report..."
	@$(GO) tool cover -func=$(COVER_PROFILE)

.PHONY: clean
clean: ## Remove build artifacts and temporary files
	$(ECHO) "Cleaning up..."
	@$(GO) clean -cache -testcache -modcache
	@find . -type f -name '*.got.*' -delete
	@find . -type f -name '*.out' -delete
	@rm -f $(COVER_PROFILE)

.PHONY: install-snap
install-snap: ## Install Snap (for Debian-based systems)
	$(ECHO) "Installing Snap..."
	@sudo apt-get update
	@sudo apt-get install -y snapd
	@sudo snap refresh

.PHONY: install-deps
install-deps: ## Install development dependencies (for Debian-based systems)
	$(ECHO) "Installing dependencies..."
	@$(MAKE) install-snap
	@sudo snap install go --classic
	@sudo snap install golangci-lint --classic
	@sudo apt-get install -y python3-poetry
	@$(GO) install github.com/google/pprof@latest
	@$(GO) mod download

.PHONY: lint
lint: format ## Run the linter checks
	$(ECHO) "Linting Go files..."
	@golangci-lint run ./...

.PHONY: download-data
download-data: ## Download the datasets used in the examples
	@echo "Downloading datasets..."
	@$(SHELL) $(DATA_DIR)/download_datasets.sh $(DATA_DIR) $(HF_DATASET)

.PHONY: download-data-large
download-data-large: ## Download the large datasets used in the examples
	@echo "Downloading large datasets..."
	@$(SHELL) $(DATA_DIR)/download_datasets.sh $(DATA_DIR) "$(HF_DATASET)-large"

.PHONY: run-examples
run-examples: format ## Run the examples
	@echo "Running the examples..."
	@HANN_LOG=$(HANN_LOG) HANN_SEED=$(HANN_SEED) $(GO) run $(EXAMPLES_DIR)/simple_hnsw.go
	@HANN_LOG=$(HANN_LOG) $(GO) run $(EXAMPLES_DIR)/hnsw.go
	@HANN_LOG=$(HANN_LOG) $(GO) run $(EXAMPLES_DIR)/pqivf.go
	@HANN_LOG=$(HANN_LOG) $(GO) run $(EXAMPLES_DIR)/rpt.go

.PHONY: run-examples-large
run-examples-large: format ## Run the examples (large datasets)
	@echo "Running the examples that use large datasets..."
	@HANN_LOG=$(HANN_LOG) $(GO) run $(EXAMPLES_DIR)/hnsw_large.go
	@HANN_LOG=$(HANN_LOG) $(GO) run $(EXAMPLES_DIR)/pqivf_large.go
	@HANN_LOG=$(HANN_LOG) $(GO) run $(EXAMPLES_DIR)/rpt_large.go

.PHONY: run-benches
run-benches: format ## Run the benchmarks
	@echo "Running the benchmarks..."
	@HANN_LOG=$(HANN_LOG) HANN_BENCH_NTRD=$(HANN_BENCH_NTRD) $(GO) run $(EXAMPLES_DIR)/bench_hnsw.go
	@HANN_LOG=$(HANN_LOG) HANN_BENCH_NTRD=$(HANN_BENCH_NTRD) $(GO) run $(EXAMPLES_DIR)/bench_pqivf.go
	@HANN_LOG=$(HANN_LOG) HANN_BENCH_NTRD=$(HANN_BENCH_NTRD) $(GO) run $(EXAMPLES_DIR)/bench_rpt.go
