# Makefile for soothe-sdk Package
#
# Manages the soothe-sdk package independently (shared contracts).
# In the monorepo, prefer root `make sync` / `uv sync --all-packages` and run
# format/lint/test targets here without sync-dev (avoids pruning the workspace).
#
# Optional: set UV_RUN='uv run --no-sync' after a forced override in CI.
UV_RUN ?= uv run

.PHONY: sync sync-dev format format-check lint lint-fix \
	test test-unit test-coverage \
	build publish publish-test clean help

# Default target
help:
	@echo "soothe-sdk Package"
	@echo ""
	@echo "Development:"
	@echo "  make sync            - Sync dependencies with uv"
	@echo "  make sync-dev        - Sync dev dependencies"
	@echo "  make format          - Format code with ruff"
	@echo "  make format-check    - Check code formatting (for CI)"
	@echo "  make lint            - Lint code with ruff"
	@echo "  make lint-fix        - Auto-fix linting issues with ruff"
	@echo ""
	@echo "Testing:"
	@echo "  make test            - Run all tests"
	@echo "  make test-unit       - Run unit tests only"
	@echo "  make test-coverage   - Run tests with coverage report"
	@echo ""
	@echo "Building & Publishing:"
	@echo "  make build           - Build the package"
	@echo "  make publish         - Publish package to PyPI"
	@echo "  make publish-test    - Publish package to TestPyPI"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean           - Clean build artifacts"

# Sync dependencies (standalone package / CI)
sync:
	@echo "Syncing dependencies..."
	uv sync
	@echo "✓ Dependencies synced"

# Sync dev dependencies (standalone package / CI)
sync-dev:
	@echo "Syncing dev dependencies..."
	uv sync --extra dev
	@echo "✓ Dev dependencies synced"

# Format code
format:
	@echo "Formatting code..."
	$(UV_RUN) ruff format src/ tests/
	@echo "✓ Code formatted"

# Check formatting (for CI)
format-check:
	@echo "Checking code formatting..."
	$(UV_RUN) ruff format --check src/ tests/
	@echo "✓ Format check passed"

# Lint code
lint:
	@echo "Linting code..."
	$(UV_RUN) ruff check src/ tests/
	@echo "✓ Linting complete"

# Auto-fix linting issues
lint-fix:
	@echo "Auto-fixing linting issues..."
	$(UV_RUN) ruff check --fix src/ tests/
	@echo "✓ Linting issues fixed"

# Run all tests
test: test-unit
	@echo "✓ All tests complete"

# Run unit tests only (skip integration)
test-unit:
	@echo "Running unit tests..."
	$(UV_RUN) pytest tests/ -v --tb=short --ignore=tests/test_integration.py
	@echo "✓ Unit tests complete"

# Run tests with coverage
test-coverage:
	@echo "Running tests with coverage..."
	$(UV_RUN) pytest tests/ --cov=soothe_sdk --cov-report=term-missing --cov-report=html \
		--ignore=tests/test_integration.py
	@echo "✓ Coverage report generated in htmlcov/"

# Build package
build:
	@echo "Building package..."
	uv build --out-dir dist
	@echo "✓ Package built"

# Publish package to PyPI
publish:
	@echo "Publishing package to PyPI..."
	uv publish dist/* --native-tls
	@echo "✓ Package published to PyPI"

# Publish package to TestPyPI
publish-test:
	@echo "Publishing package to TestPyPI..."
	uv publish dist/* --index-url https://test.pypi.org/simple/ --native-tls
	@echo "✓ Package published to TestPyPI"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf dist/ *.egg-info .pytest_cache .coverage .ruff_cache htmlcov/
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	@echo "✓ Build artifacts cleaned"
