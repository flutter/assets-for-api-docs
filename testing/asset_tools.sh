#!/bin/bash
set -e

if [[ "$1" == "analyze" ]]; then
  echo "Analyzing Dart files."
  (cd src && flutter analyze)
elif [[ "$1" == "test" ]]; then
  echo "Running tests."
  (cd src && flutter test)
fi