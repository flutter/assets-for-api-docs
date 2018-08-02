#!/bin/bash
# A script that will do packages get for each package in the repo.
set -e

if [[ -n '$CIRRUS_CI' ]]; then
  export PATH="$FLUTTER_DIR/bin:$FLUTTER_DIR/bin/cache/dart-sdk/bin:$PATH"
fi

# So that users can run this script from anywhere and it will work as expected.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Update packages in the relevant package directories.
for dir in "$REPO_DIR/bin" "$REPO_DIR/packages/"* "$REPO_DIR/utils/"*; do
  (cd "$dir" && flutter packages get)
done

# Also update packages just with pub in bin, since there are non-flutter packages
# there.
(cd "$REPO_DIR/bin" && pub get)
