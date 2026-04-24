#!/usr/bin/env bash
set -euo pipefail

# Publish this repository to GitHub and create a release with the skill zip attached.
# Requirements:
#   - GitHub CLI: https://cli.github.com/
#   - gh auth login
# Usage:
#   ./scripts/publish-github.sh --owner Macrolv --repo system-debug-skill --public --tag v1.0.0

OWNER="${GITHUB_OWNER:-}"
REPO="${GITHUB_REPO:-system-debug-skill}"
VISIBILITY="public"
TAG="v1.0.0"
TITLE="system-debug v1.0.0"
REMOTE="origin"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner) OWNER="${2:?missing owner}"; shift 2 ;;
    --repo) REPO="${2:?missing repo}"; shift 2 ;;
    --public) VISIBILITY="public"; shift ;;
    --private) VISIBILITY="private"; shift ;;
    --tag) TAG="${2:?missing tag}"; shift 2 ;;
    --title) TITLE="${2:?missing title}"; shift 2 ;;
    --remote) REMOTE="${2:?missing remote}"; shift 2 ;;
    -h|--help)
      sed -n '1,40p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$OWNER" ]]; then
  OWNER="$(gh api user --jq .login 2>/dev/null || true)"
fi
if [[ -z "$OWNER" ]]; then
  echo "Could not determine GitHub owner. Pass --owner <username-or-org>." >&2
  exit 1
fi

command -v git >/dev/null || { echo "git is required" >&2; exit 1; }
command -v gh >/dev/null || { echo "GitHub CLI 'gh' is required. Install it and run: gh auth login" >&2; exit 1; }
gh auth status >/dev/null

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

./scripts/validate.sh
./scripts/package.sh

FULL_REPO="$OWNER/$REPO"

if [[ ! -d .git ]]; then
  git init
fi

git branch -M main

git add .
if ! git diff --cached --quiet; then
  git commit -m "Initial release of system-debug skill"
fi

if gh repo view "$FULL_REPO" >/dev/null 2>&1; then
  if git remote get-url "$REMOTE" >/dev/null 2>&1; then
    git remote set-url "$REMOTE" "git@github.com:$FULL_REPO.git"
  else
    git remote add "$REMOTE" "git@github.com:$FULL_REPO.git"
  fi
else
  gh repo create "$FULL_REPO" "--$VISIBILITY" --description "System-debug skill: root-cause software debugging workflow" --source=. --remote="$REMOTE" --push
fi

git push -u "$REMOTE" main

if git rev-parse "$TAG" >/dev/null 2>&1; then
  git tag -f "$TAG"
else
  git tag "$TAG"
fi
git push "$REMOTE" "$TAG" --force

RELEASE_NOTES="$(mktemp)"
cat > "$RELEASE_NOTES" <<NOTES
# system-debug $TAG

Initial public release of the system-debug skill.

## Install

### Claude Code user install

\`\`\`bash
unzip system-debug.zip -d ~/.claude/skills
\`\`\`

### Claude Code project install

\`\`\`bash
mkdir -p .claude/skills
unzip system-debug.zip -d .claude/skills
\`\`\`

## SHA-256

See \`checksums.txt\`.
NOTES

if gh release view "$TAG" --repo "$FULL_REPO" >/dev/null 2>&1; then
  gh release edit "$TAG" --repo "$FULL_REPO" --title "$TITLE" --notes-file "$RELEASE_NOTES"
  gh release upload "$TAG" dist/system-debug.zip dist/checksums.txt --repo "$FULL_REPO" --clobber
else
  gh release create "$TAG" dist/system-debug.zip dist/checksums.txt --repo "$FULL_REPO" --title "$TITLE" --notes-file "$RELEASE_NOTES"
fi

rm -f "$RELEASE_NOTES"

echo "Published: https://github.com/$FULL_REPO"
echo "Release:   https://github.com/$FULL_REPO/releases/tag/$TAG"
