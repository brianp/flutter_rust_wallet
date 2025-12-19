#!/usr/bin/env bash
set -euo pipefail

REPO_URL="git@github.com:tari-project/minotari-cli.git"
REPO_NAME="minotari-cli"

# Clone repo if it doesn't exist
if [ ! -d "$REPO_NAME" ]; then
  git clone "$REPO_URL"
fi

cd "$REPO_NAME"

# Create data directory
mkdir -p data

# Absolute path to wallet.db
DATA_DIR="$(cd data && pwd)"
export DATABASE_URL="sqlite://${DATA_DIR}/wallet.db"

echo "DATABASE_URL set to:"
echo "  $DATABASE_URL"

# Run sqlx commands
sqlx database create
sqlx migrate run

# Move out two directories
cd ../..

# Enter rust directory
cd rust

# Build Rust project
cargo build

echo "Rust build complete."
echo "DATABASE_URL is still available in this shell."
