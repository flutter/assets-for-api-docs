#!/bin/bash
set -e

# So that users can run this script from anywhere and it will work as expected.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

if [[ -n "$CIRRUS_CI" ]]; then
  echo "Updating PATH."
  export PATH="$FLUTTER_DIR/bin:$FLUTTER_DIR/bin/cache/dart-sdk/bin:$PATH"
else
  echo "Updating packages."
  "$SCRIPT_DIR/update_packages.sh"
fi

# Default to the first arg if SHARD isn't set, and to "test" if neither are set.
SHARD="${SHARD:-${1:-test}}"

if [[ "$SHARD" == "analyze" ]]; then
  echo "Analyzing Dart files."
  for dir in bin packages utils; do
    (cd "$REPO_DIR/$dir" && flutter analyze)
  done
elif [[ "$SHARD" == "test" ]]; then
  echo "Running tests."
  (cd "$REPO_DIR/bin" && pub run test/generate_test.dart)
  (cd "$REPO_DIR/packages/diagram_capture" && flutter test)
fi
