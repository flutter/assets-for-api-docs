# CI Scripts

This directory contains scripts that are either used by the continuous
integration (CI) system, or are useful to the deveoper for diagnosing issues
encountered in CI.

## [fix_format](fix_format)

This script will fix any formatting issues in the repo.

## [pub_upgrade](pub_upgrade)

This script will run `flutter pub upgrade` in each of the directories that contain a pubspec.yaml in the repo.

## [check](check)

This script will run any or all of the tests that the CI system runs, using the
same mechanism. If no check is specified, all are run.

You may also tell `check` to not automatically activate the
[`flutter_plugin_tools`](https://pub.dev/packages/flutter_plugin_tools) package
with the `--no-activate` option.

### `analyze` Check

Runs the Flutter analyzer on the code in the repo.

### `license-check` Check

Checks for existence of a proper license file and copyright blocks in all source
files for packages in this repo.

### `publish-check` Check

Checks that each of the packages marked as publishable are able to be published.
Will skip any packages with `publish_to: none` in their `pubspec.yaml`

### `pubspec-check` Check

Checks that pubspecs are formatted properly and have the correct fields.

### `test` Check

Runs any tests in the `test` directory of each package.

### `version-check` Check

Checks that the `CHANGELOG.md` for each package has an entry for the current and
previous versions.

## [tool_runner.sh](tool_runner.sh)

A helper script used by the CI system to minimize the number of checks run on
pull requests by not running checks in packages that have no changes. No tests
are skipped in post-submit runs.