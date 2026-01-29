#!/bin/bash
# Stencila wrapper script - executes Stencila commands in the stencila-tool container
# Usage: stencila-wrapper.sh <stencila-command> [args...]
#
# Run from the project directory (or a subdir). Relative paths (e.g. test.smd) are
# resolved inside the container using the same workspace mount at /workspaces/generative_methods.

set -euo pipefail

# Use release binary by default (use /workspace/target/debug/stencila for debug builds)
# STENCILA_BINARY="${STENCILA_BINARY:-/workspace/target/release/stencila}"
STENCILA_BINARY="${STENCILA_BINARY:-/workspace/target/debug/stencila}"
STENCILA_CONTAINER="${STENCILA_CONTAINER:-stencila-tool}"

# Use caller's cwd so relative paths (e.g. test.smd) resolve correctly. The project
# is mounted at /workspaces/generative_methods in both generative-methods and stencila-tool.
docker exec -w "$(pwd)" "${STENCILA_CONTAINER}" "${STENCILA_BINARY}" "$@"
