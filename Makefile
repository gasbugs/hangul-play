.PHONY: all check security test integration build help

IMAGE = ghcr.io/cirruslabs/flutter:stable
APP_IMAGE = hangul-play:latest
DOCKER_RUN = docker run --rm -v $(PWD):/app -w /app $(IMAGE)

all: check security test integration build

check:
	@echo "--- [1/5] Running Flutter Static Analysis (Container) ---"
	$(DOCKER_RUN) flutter analyze

test:
	@echo "--- [2/5] Running Flutter Unit Tests (Container) ---"
	$(DOCKER_RUN) flutter test

security:
	@echo "--- [3/5] Running Security & 12 Factor Audit (Container) ---"
	@chmod +x scripts/ci-audit.sh
	$(DOCKER_RUN) /bin/bash ./scripts/ci-audit.sh

integration:
	@echo "--- [4/5] Running Flutter Integration Tests (Container) ---"
	@echo "INFO: Skipping integration tests as no devices are connected."
	@# $(DOCKER_RUN) flutter test integration_test

build:
	@echo "--- [5/5] Building Production Container Image ---"
	docker build -t $(APP_IMAGE) .

help:
	@echo "Available commands:"
	@echo "  make all         - Run all CI checks and build image via Docker"
	@echo "  make check       - Run flutter analyze inside container"
	@echo "  make test        - Run flutter unit tests inside container"
	@echo "  make security    - Run security audit inside container"
	@echo "  make integration - Run integration tests inside container"
	@echo "  make build       - Build production Docker image"
