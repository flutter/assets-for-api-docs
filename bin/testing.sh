#!/bin/bash
set -e

if [[ -n '$CIRRUS_CI' ]]; then
  export PATH="$FLUTTER_DIR/bin:$FLUTTER_DIR/bin/cache/dart-sdk/bin:$PATH"
fi

# So that users can run this script from anywhere and it will work as expected.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

if [[ "$1" == "analyze" ]]; then
  echo "Analyzing Dart files."
  for dir in bin packages utils; do
    (cd "$REPO_DIR/$dir" && flutter analyze)
  done
elif [[ "$1" == "test" ]]; then
  echo "Running tests."
  (cd "$REPO_DIR/bin" && pub run test/generate_test.dart)
  (cd "$REPO_DIR/packages/diagram_capture" && flutter test)
fi
