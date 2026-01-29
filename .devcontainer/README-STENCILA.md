# Stencila Tool Container Integration

This project is configured to use the Stencila tool container via Docker Compose.

## Setup

1. **Update the Stencila repository path** in `docker-compose.yml`:
   - Find the `stencila-tool` service
   - Update the `context` path to point to your Stencila repository (e.g., `../stencila`)
   - Update the volume mount path to match

2. **Configure Docker Desktop resources** (required for Rust builds):
   - Open Docker Desktop > Settings > Resources > Advanced
   - **Memory**: Set to at least 12GB (16GB+ recommended for faster builds)
   - **CPUs**: Set to at least 6 cores (8+ recommended)
   - Click "Apply & Restart"
   
   The `stencila-tool` container is configured with resource limits:
   - Up to 6 CPU cores for parallel compilation
   - Up to 12GB RAM for the build process

3. **Build the Stencila container** (first time only):
   ```bash
   docker-compose build stencila-tool
   ```

4. **Stencila debug binary**: 
   - **Always rebuilt on startup**: The debug binary is **always rebuilt** when you start the containers (`docker compose up` / devcontainer rebuild). The `stencila-tool` service runs `cargo build --bin stencila` on startup, then stays running.
   - **Skip build manually**: Set `SKIP_STENCILA_BUILD=1` environment variable to skip the build:
     ```bash
     SKIP_STENCILA_BUILD=1 docker-compose up
     ```
   - **Healthcheck**: The `generative-methods` service waits until the binary is ready (healthcheck passes) before starting. The healthcheck allows up to 10 minutes for the build to complete.

## Usage

### Using the wrapper script (recommended)

After the devcontainer is created, you can use the `stencila` command directly:

```bash
# Check version
stencila --version

# Convert a document
stencila convert input.md output.html
```

### Using docker exec directly

```bash
# Check version
docker exec stencila-tool /workspace/target/debug/stencila --version

# Convert a document
docker exec stencila-tool /workspace/target/debug/stencila convert input.md output.html
```

### Rebuilding Stencila

The debug binary is rebuilt on every `docker compose up`. If you change Stencila source and want to rebuild without restarting:

```bash
docker exec stencila-tool bash -c "cd /workspace/rust && cargo build --bin stencila"
```

For a release build: add `--release` and use `/workspace/target/release/stencila` (set `STENCILA_BINARY` accordingly).

## Binary Locations

- **Release binary** (recommended): `/workspace/target/release/stencila`
- **Debug binary** (for development): `/workspace/target/debug/stencila`

To use the debug binary, set the environment variable:
```bash
export STENCILA_BINARY=/workspace/target/debug/stencila
```

## Troubleshooting

- **Container not found**: Ensure `docker-compose up -d` has been run
- **Binary not found**: Build it first (see Setup step 3) or check if build is still in progress
- **Container exits with code 137**: This usually means the container was killed, often due to:
  - **Out of memory (OOM)**: The Rust build is memory-intensive and requires significant resources:
    - Ensure Docker Desktop has at least 12GB RAM allocated (Settings > Resources > Advanced)
    - Ensure Docker Desktop has at least 6 CPU cores allocated
    - The container is configured with resource limits, but Docker Desktop must have enough resources available
    - If still having issues, try skipping the build: `SKIP_STENCILA_BUILD=1 docker-compose up`
    - Build manually later: `docker exec stencila-tool bash -c "cd /workspace/rust && cargo build --bin stencila"`
  - **Build taking too long**: The healthcheck allows 10 minutes. If build takes longer, check logs:
    ```bash
    docker-compose logs -f stencila-tool
    ```
- **Permission denied**: The binary should be executable by default
- **File not found**: Run `stencila` from the project directory (or a subdir). The workspace is mounted at `/workspaces/generative_methods` in the stencila-tool container; relative paths (e.g. `test.smd`) resolve from your current working directory.
- **Build fails on startup**: The container will continue running even if the build fails. Check logs and rebuild manually:
  ```bash
  docker-compose logs stencila-tool
  docker exec stencila-tool bash -c "cd /workspace/rust && cargo build --bin stencila"
  ```
