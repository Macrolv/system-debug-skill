#!/usr/bin/env bash
set -euo pipefail

REPOSITORY="${SYSTEM_DEBUG_REPOSITORY:-Macrolv/system-debug-skill}"
REF="${SYSTEM_DEBUG_REF:-main}"
SKILL_NAME="system-debug"
SCOPE="user"
PROJECT_PATH=""
FORCE=0
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage:
  curl -fsSL https://raw.githubusercontent.com/Macrolv/system-debug-skill/main/scripts/install-remote.sh | bash
  curl -fsSL https://raw.githubusercontent.com/Macrolv/system-debug-skill/main/scripts/install-remote.sh | bash -s -- --project .

Options:
  --user                 Install to ~/.claude/skills/system-debug (default)
  --project [path]       Install to <path>/.claude/skills/system-debug. Defaults to current directory.
  --force                Replace existing installation
  --dry-run              Print actions without copying files
  --repo owner/name      GitHub repository to install from. Default: Macrolv/system-debug-skill
  --ref ref              Branch or tag to install from. Default: main
  -h, --help             Show help
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --user)
      SCOPE="user"; shift ;;
    --project)
      SCOPE="project"
      if [ $# -gt 1 ] && [[ "$2" != --* ]]; then
        PROJECT_PATH="$2"; shift 2
      else
        PROJECT_PATH="$(pwd)"; shift
      fi
      ;;
    --force)
      FORCE=1; shift ;;
    --dry-run)
      DRY_RUN=1; shift ;;
    --repo)
      REPOSITORY="${2:?Missing value for --repo}"; shift 2 ;;
    --ref)
      REF="${2:?Missing value for --ref}"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: '$1' is required." >&2
    exit 1
  fi
}

need curl
need unzip
need mktemp

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
TMPDIR="$(mktemp -d)"
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

ZIP="$TMPDIR/source.zip"
URL="https://github.com/$REPOSITORY/archive/refs/heads/$REF.zip"

if ! curl -fsSL "$URL" -o "$ZIP"; then
  URL="https://github.com/$REPOSITORY/archive/refs/tags/$REF.zip"
  curl -fsSL "$URL" -o "$ZIP"
fi

unzip -q "$ZIP" -d "$TMPDIR/src"
SOURCE_DIR="$(find "$TMPDIR/src" -type f -path "*/$SKILL_NAME/SKILL.md" -print -quit | sed "s#/SKILL.md##")"

if [ -z "${SOURCE_DIR:-}" ] || [ ! -f "$SOURCE_DIR/SKILL.md" ]; then
  echo "Error: could not find $SKILL_NAME/SKILL.md in downloaded archive." >&2
  exit 1
fi

if ! grep -q '^name: system-debug$' "$SOURCE_DIR/SKILL.md"; then
  echo "Error: downloaded SKILL.md does not declare name: system-debug" >&2
  exit 1
fi

echo "Installing $SKILL_NAME from $REPOSITORY@$REF"
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

echo "Installed successfully."
echo "Installed path: $TARGET_DIR"
echo "Try: /system-debug diagnose why this test is failing"
