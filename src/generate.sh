#!/bin/bash

set -e

function find_project_dir() {
    local project_path="$(realpath $0)"
    echo "${project_path%/*}"
}

PROJECT_DIR=$(find_project_dir)

function collect_image() {
    local dart_file="$1"
    local type="${dart_file%/*}"
    local base="${dart_file##*/}"
    base="${base%.dart}"
    local dart_path="${PROJECT_DIR}/${dart_file}"
    local tmpdir="/tmp/${type}"
    local process_script="${tmpdir}/${type}.sh"

    rm -rf "${tmpdir}"
    mkdir -p "${tmpdir}"

    echo "Running ${dart_file} from ${PROJECT_DIR}."

    # This is run in the background and later killed because running with
    # --no-resident doesn't keep producing stdout long enough before it exits
    # to write the process script for generators that rely on waiting for
    # animations to complete.
    (cd "${PROJECT_DIR}" && flutter run "${dart_file}" | \
     awk -F: '/^I\/flutter.*BASH:/ {print $3}') > "${process_script}" &
    bg_pid=$!

    # This needs to be long enough for the build-start-run sequence to be
    # complete.
    sleep 15
    echo "Capturing screen shot."
    (cd "${PROJECT_DIR}" && flutter screenshot --out="${tmpdir}/flutter_01.png")

    kill ${bg_pid} || true

    echo "Processing screen shot."
    (cd "${tmpdir}" && bash "${process_script}")

    echo "Optimizing and copying new assets into place."
    for file in "${tmpdir}/${base}"*.png; do
        local dest="${PROJECT_DIR}/../${type}/${file##*/}"
        echo "Optimizing PNG file $file into ${dest}"
        rm -f "${dest}"
        optipng -zc1-9 -zm1-9 -zs0-3 -f0-5 "${file}" -out "${dest}"
    done
    rm -rf "${tmpdir}"
}

horizontal_apps=(
     material/app_bar.dart material/card.dart material/ink_response_large.dart
     material/ink_response_small.dart material/ink_well.dart)

vertical_apps=(animation/curve.dart dart-ui/tile_mode.dart painting/box_fit.dart)

if [[ -z "$1" || "$1" == "--help" ]]; then
  echo "At least one generator dart file must be specified, or '--horizontal'"
  echo "or '--vertical', depending on the orientation of the generating device."
  echo "Available vertical generators are:"
  for app in "${vertical_apps[@]}"; do
    echo "  ${app}"
  done
  echo "Available horizontal generators are:"
  for app in "${horizontal_apps[@]}"; do
    echo "  ${app}"
  done
  exit 0
fi

if [[ "$1" == "--horizontal" ]]; then
    echo "Be sure the device is in a horizontal orientation..."
    apps=("${horizontal_apps[@]}")
elif [[ "$1" == "--vertical" ]]; then
    echo "Be sure the device is in a vertical orientation..."
    apps=("${vertical_apps[@]}")
else
    apps=("$@")
fi

for app in "${apps[@]}"; do
    (collect_image "${app}")
done
