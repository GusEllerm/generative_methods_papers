# Stencila Tool Container Integration

This project is configured to use the Stencila tool container via Docker Compose.

## Setup

1. **Update the Stencila repository path** in `docker-compose.yml`:
   - Find the `stencila-tool` service
   - Update the `context` path to point to your Stencila repository (e.g., `../stencila`)
   - Update the volume mount path to match

2. **Build the Stencila container** (first time only):
   ```bash
   docker-compose build stencila-tool
   ```

3. **Build the Stencila binary** (first time only):
   ```bash
   docker exec stencila-tool bash -c "cd /workspace/rust && cargo build --bin stencila --release"
   ```

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

If you modify the Stencila source code:

```bash
docker exec stencila-tool bash -c "cd /workspace/rust && cargo build --bin stencila --release"
```

## Binary Locations

- **Release binary** (recommended): `/workspace/target/release/stencila`
- **Debug binary** (for development): `/workspace/target/debug/stencila`

To use the debug binary, set the environment variable:
```bash
export STENCILA_BINARY=/workspace/target/debug/stencila
```

## Troubleshooting

- **Container not found**: Ensure `docker-compose up -d` has been run
- **Binary not found**: Build it first (see Setup step 3)
- **Permission denied**: The binary should be executable by default
- **File not found**: Run `stencila` from the project directory (or a subdir). The workspace is mounted at `/workspaces/generative_methods` in the stencila-tool container; relative paths (e.g. `test.smd`) resolve from your current working directory.
