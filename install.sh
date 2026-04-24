#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  ./install.sh --user [--force] [--dry-run]
  ./install.sh --project [PROJECT_PATH] [--force] [--dry-run]

Options:
  --user                 Install to ~/.claude/skills/system-debug
  --project [path]       Install to <path>/.claude/skills/system-debug. Defaults to current directory.
  --force                Replace existing installation
  --dry-run              Print actions without copying files
  -h, --help             Show help
USAGE
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/system-debug"
SKILL_NAME="system-debug"
SCOPE=""
PROJECT_PATH=""
FORCE=0
DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    --user)
      SCOPE="user"
      shift
      ;;
    --project)
      SCOPE="project"
      if [ $# -gt 1 ] && [[ "$2" != --* ]]; then
        PROJECT_PATH="$2"
        shift 2
      else
        PROJECT_PATH="$(pwd)"
        shift
      fi
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ -z "$SCOPE" ]; then
  SCOPE="user"
fi

if [ ! -f "$SOURCE_DIR/SKILL.md" ]; then
  echo "Error: source skill not found at $SOURCE_DIR/SKILL.md" >&2
  exit 1
fi

case "$SCOPE" in
  user)
    TARGET_BASE="${HOME:?}/.claude/skills"
    ;;
  project)
    PROJECT_PATH="${PROJECT_PATH:-$(pwd)}"
    TARGET_BASE="$PROJECT_PATH/.claude/skills"
    ;;
  *)
    echo "Internal error: unknown scope $SCOPE" >&2
    exit 1
    ;;
esac

TARGET_DIR="$TARGET_BASE/$SKILL_NAME"

echo "Installing $SKILL_NAME"
echo "Source: $SOURCE_DIR"
echo "Target: $TARGET_DIR"

if [ "$DRY_RUN" -eq 1 ]; then
  echo "Dry run only; no files copied."
  exit 0
fi

mkdir -p "$TARGET_BASE"

if [ -e "$TARGET_DIR" ]; then
  if [ "$FORCE" -ne 1 ]; then
    echo "Error: $TARGET_DIR already exists. Re-run with --force to replace it." >&2
    exit 1
  fi
  rm -rf "$TARGET_DIR"
fi

cp -R "$SOURCE_DIR" "$TARGET_DIR"
chmod +x "$TARGET_DIR/find-polluter.sh" 2>/dev/null || true

if [ ! -f "$TARGET_DIR/SKILL.md" ]; then
  echo "Error: installation failed; SKILL.md missing at target." >&2
  exit 1
fi

if ! grep -q '^name: system-debug$' "$TARGET_DIR/SKILL.md"; then
  echo "Warning: installed SKILL.md does not contain expected name: system-debug" >&2
fi

echo "Installed successfully."
echo "Try: /system-debug diagnose why this test is failing"
