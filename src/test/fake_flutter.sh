#!/usr/bin/env bash

script_dir=$( cd "$(dirname "$0")" ; pwd -P )

if [[ "$1" == "run" ]]; then
  echo "I/flutter COMMAND: ${script_dir}/fake_flutter.sh crop"
  echo "DONE DRAWING"
fi

if [[ "$1" == "crop" ]]; then
  echo "Cropped file"
fi
