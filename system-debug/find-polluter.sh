#!/usr/bin/env bash
# Bisection-style helper to find which test creates unwanted files/state.
# Usage: ./find-polluter.sh <file_or_dir_to_check> <test_glob>
# Example: ./find-polluter.sh '.git' 'src/**/*.test.ts'

set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Usage: $0 <file_or_dir_to_check> <test_glob>"
  echo "Example: $0 '.git' 'src/**/*.test.ts'"
  exit 1
fi

POLLUTION_CHECK="$1"
TEST_GLOB="$2"

printf '🔍 Searching for test that creates: %s\n' "$POLLUTION_CHECK"
printf 'Test glob: %s\n\n' "$TEST_GLOB"

# Enable recursive globbing for patterns like src/**/*.test.ts.
shopt -s globstar nullglob

# shellcheck disable=SC2206
TEST_FILES=( $TEST_GLOB )
TOTAL=${#TEST_FILES[@]}

printf 'Found %s test files\n\n' "$TOTAL"

if [ "$TOTAL" -eq 0 ]; then
  echo "No tests matched the glob. Check the pattern and current directory."
  exit 2
fi

COUNT=0
for TEST_FILE in "${TEST_FILES[@]}"; do
  COUNT=$((COUNT + 1))

  if [ -e "$POLLUTION_CHECK" ]; then
    printf '⚠️  Pollution already exists before test %s/%s\n' "$COUNT" "$TOTAL"
    printf '   Remove it before continuing: %s\n' "$POLLUTION_CHECK"
    exit 3
  fi

  printf '[%s/%s] Testing: %s\n' "$COUNT" "$TOTAL" "$TEST_FILE"

  npm test "$TEST_FILE" > /dev/null 2>&1 || true

  if [ -e "$POLLUTION_CHECK" ]; then
    printf '\n🎯 FOUND POLLUTER!\n'
    printf '   Test: %s\n' "$TEST_FILE"
    printf '   Created: %s\n\n' "$POLLUTION_CHECK"
    printf 'Pollution details:\n'
    ls -la "$POLLUTION_CHECK"
    printf '\nTo investigate:\n'
    printf '  npm test %q\n' "$TEST_FILE"
    printf '  sed -n '\''1,220p'\'' %q\n' "$TEST_FILE"
    exit 1
  fi
done

printf '\n✅ No polluter found - all tests clean!\n'
exit 0
