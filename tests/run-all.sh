#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FAILED=0

echo "Running all tests..."
echo ""

for test_file in "$SCRIPT_DIR"/test-*.sh; do
  echo "--- $(basename "$test_file") ---"
  if bash "$test_file"; then
    echo ""
  else
    FAILED=1
    echo ""
  fi
done

if [ "$FAILED" -eq 1 ]; then
  echo "SOME TESTS FAILED"
  exit 1
else
  echo "ALL TESTS PASSED"
fi
