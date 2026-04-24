#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="$ROOT_DIR/system-debug"
SKILL_FILE="$SKILL_DIR/SKILL.md"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

[ -d "$SKILL_DIR" ] || fail "Missing skill directory: $SKILL_DIR"
[ -f "$SKILL_FILE" ] || fail "Missing SKILL.md: $SKILL_FILE"

grep -q '^---$' "$SKILL_FILE" || fail "SKILL.md must start with YAML frontmatter markers"
grep -q '^name: system-debug$' "$SKILL_FILE" || fail "SKILL.md frontmatter must contain name: system-debug"
grep -q '^description: ' "$SKILL_FILE" || fail "SKILL.md frontmatter must contain description"

required_files=(
  "root-cause-tracing.md"
  "defense-in-depth.md"
  "condition-based-waiting.md"
  "condition-based-waiting-example.ts"
  "find-polluter.sh"
  "UPSTREAM-SKILL.md"
  "LICENSE"
)

for file in "${required_files[@]}"; do
  [ -f "$SKILL_DIR/$file" ] || fail "Missing support file: $file"
done

# Basic safety lint: keep diagnostic examples from printing full env or common secret values.
if grep -nE 'env[[:space:]]*\|[[:space:]]*grep|printenv|echo[[:space:]]+"?\$\{?(PASSWORD|TOKEN|SECRET|API_KEY|PRIVATE_KEY|COOKIE)' "$SKILL_FILE"; then
  fail "Potential unsafe diagnostic pattern found in SKILL.md"
fi

# The distribution folder must match the skill name.
frontmatter_name="$(grep -m1 '^name: ' "$SKILL_FILE" | sed 's/^name: //')"
folder_name="$(basename "$SKILL_DIR")"
[ "$frontmatter_name" = "$folder_name" ] || fail "Skill folder '$folder_name' must match frontmatter name '$frontmatter_name'"

echo "Validation passed."
