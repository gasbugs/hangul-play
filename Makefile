.PHONY: all check security test integration help

IMAGE = ghcr.io/cirruslabs/flutter:stable
DOCKER_RUN = docker run --rm -v $(PWD):/app -w /app $(IMAGE)

all: check security test integration

check:
	@echo "--- [1/4] Running Flutter Static Analysis (Container) ---"
	$(DOCKER_RUN) flutter analyze

test:
	@echo "--- [2/4] Running Flutter Unit Tests (Container) ---"
	$(DOCKER_RUN) flutter test

security:
	@echo "--- [3/4] Running Security & 12 Factor Audit ---"
	@chmod +x scripts/ci-audit.sh
	@./scripts/ci-audit.sh

integration:
	@echo "--- [4/4] Running Flutter Integration Tests (Container) ---"
	@echo "INFO: Skipping integration tests as no devices are connected."
	@# $(DOCKER_RUN) flutter test integration_test

help:
	@echo "Available commands:"
	@echo "  make all         - Run all CI checks via Docker"
	@echo "  make check       - Run flutter analyze inside container"
	@echo "  make test        - Run flutter unit tests inside container"
	@echo "  make security    - Run local security audit script"
	@echo "  make integration - Run integration tests inside container"
