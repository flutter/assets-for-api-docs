#!/bin/bash
set -e

if [[ "$1" == "analyze" ]]; then
  echo "Analyzing Dart files."
  (cd diagrams && flutter analyze)
  (cd packages/diagram_capture && flutter analyze)
  (cd packages/diagram_capture/example/simple && flutter analyze)

elif [[ "$1" == "test" ]]; then
  echo "Running tests."
  (cd diagrams && flutter test)
  (cd packages/diagram_capture && flutter test)
fi
