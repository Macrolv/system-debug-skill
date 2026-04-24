#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

./scripts/validate.sh

rm -rf dist
mkdir -p dist

zip -r dist/system-debug.zip system-debug \
  -x '*.DS_Store' \
  -x '*/.git/*' \
  -x '*/node_modules/*' \
  -x '*/__pycache__/*' >/dev/null

(
  cd dist
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 system-debug.zip > checksums.txt
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum system-debug.zip > checksums.txt
  else
    echo "No SHA-256 tool found; skipping checksum." >&2
  fi
)

echo "Created dist/system-debug.zip"
[ -f dist/checksums.txt ] && echo "Created dist/checksums.txt"
