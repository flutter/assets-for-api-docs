#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -e

# So that users can run this script from anywhere and it will work as expected.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

if [[ -n "$CIRRUS_CI" ]]; then
  echo "Updating PATH."
  export PATH="$FLUTTER_DIR/bin:$FLUTTER_DIR/bin/cache/dart-sdk/bin:$PATH"
else
  echo "Updating packages."
  "$SCRIPT_DIR/pub_upgrade.sh"
fi

# Default to the first arg if SHARD isn't set, and to "test" if neither are set.
SHARD="${SHARD:-${1:-test}}"

function test_packages() {
  for dir in "$REPO_DIR/packages/"* "$REPO_DIR/utils/"*; do
    if [[ -e "$dir/pubspec.yaml" && -e "$dir/test" ]]; then
      (cd "$dir" && flutter test)
    fi
  done
}

function test_publishable() {
  for dir in "$REPO_DIR/packages/"* "$REPO_DIR/utils/"*; do
    if [[ -e "$dir/CHANGELOG.md" ]]; then
      (cd "$dir" && pub publish --dry-run)
    fi
  done
}

if [[ "$SHARD" == "test" ]]; then
  echo "Running tests."
  (cd "$REPO_DIR/bin" && pub run test)
  test_packages
  echo "Checking publishability."
  test_publishable
fi