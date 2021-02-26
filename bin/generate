#!/bin/bash
set -e

# So that users can run this script from anywhere and it will work as expected.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Dart needs to be in the path already...
(cd ${REPO_DIR}/bin; pub get)
dart --no-sound-null-safety "${REPO_DIR}/bin/generate.dart" "$@"
