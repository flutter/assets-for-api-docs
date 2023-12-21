# assets-for-api-docs

This repo is used to host and serve static assets in support of
[docs.flutter.dev](https://docs.flutter.dev), as well as some manual tests that use
specially-crafted graphics.

Assets committed to this repo and pushed to GitHub are immediately
available for linking and reference.

## Adding new assets

In accordance with the [Flutter style guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo#provide-illustrations-diagrams-or-screenshots),
assets submitted to this repository should be easily reproducible, e.g. by
running a Flutter app or a script. This makes it easier to update the asset in
the future, if needed. Check the existing diagrams (and their generation code)
in this repository to see examples. Avoid checking in just a static image file
(e.g. PNG, JPEG), without a way to regenerate and update it.

## Creating new diagrams

To create a new diagram:

1. Create a new Dart file inside `/packages/diagrams/lib/src/`.

2. Export that file from `/packages/diagrams/lib/diagrams.dart`.

3. Create one or more diagram widgets that mix-in `DiagramMetadata`, overriding the `name` getter to return their name,
   which should be lower_snake_case.

    * If your diagram is animated, override the `duration` getter to return the duration of the animation.

    * If your diagram's state needs to wait imperatively, mix-in `LockstepStateMixin` and call `waitLockstep(duration)`.

    * If your diagram needs simulated gesture input, acquire a [WidgetController](https://api.flutter.dev/flutter/flutter_test/WidgetController-class.html)
      by calling `DiagramWidgetController.of(context)`.

4. Create a class that extends `DiagramStep`.

5. Override the `diagrams` getter of `DiagramStep` to return a list containing the new diagrams.

6. Override the `category` getter of `DiagramStep` to return the category it belongs in, this corresponds to the folders
   under `/assets`.

7. Add your new `DiagramStep` to the list in `packages/diagrams/lib/src/steps.dart`, sorted alphabetically.

8. Generate assets with `bin/generate -s MyDiagramStep`, for more options see the [generation](#Generation) section.

## URL structure

Reference the assets with this URL structure:

`https://flutter.github.io/assets-for-api-docs/assets/<library>/<asset>`

For example, an image named `app_bar.png` about `AppBar` from the
material library would go in the `assets/material/` directory and be at
`https://flutter.github.io/assets-for-api-docs/assets/material/app_bar.png`.

All asset files should be under the `assets` directory in an appropriate
subdirectory.

## Generation

Images must be code-generated.

To create new images, see the [`packages/diagrams/lib/src/`](./packages/diagrams/lib/src/) directory.

The [`generate.dart`](./bin/generate.dart) script regenerates almost all of existing assets
using the Flutter version you have installed. A small wrapper [`bin/generate`](./bin/generate)
([`bin\generate.bat`](./bin/generate.bat) on Windows)
is provided as a convenience.

To limit image generation to certain categories and/or names, run:
```sh
# Filter by category
bin/generate -c cupertino,material
# Filter by name
bin/generate -n basic_material_app,blend_mode
# Filter by step class name
bin/generate -s MaterialAppDiagramStep,BlendModeDiagramStep
```

`bin/generate --help` lists available arguments.

### Prerequisites

The `generate.dart` script works on macOS, Linux, and Windows, but it needs several prerequisites in order to run. On
Linux and macOS run `bin/generate`. On Windows, run `bin\generate.bat`.

To optimize PNG files, it needs `optipng`, which is available for macOS via Homebrew, and Linux via
apt-get, and Windows from the [optipng website](http://optipng.sourceforge.net/).

To convert animations into mp4 files, it needs `ffmpeg`, available for macOS via Homebrew and Linux
via apt-get, and for Windows from the [FFMPEG website](https://ffmpeg.org/download.html).

Both `optipng` and `ffmpeg` need to be in your path when you run the generate script.

The commands `flutter`, `dart`, and (when using an Android device) `adb` need to be available
in a directory in the `PATH` environment variable (e.g. `PATH=~/<path_to_flutter>/flutter/bin/cache/dart-sdk/bin:~/Android/Sdk/platform-tools:$PATH`).
The script needs the most recent development version of Flutter and is _not_ intended to work with released Flutter versions.

When using an Android device, be sure that the  `adb` command is the same as the one running
as a server (which is often started by your IDE, so use the same `adb` the IDE is running).

You cannot currently generate docs on an iOS device (although you can generate them on macOS).

## Optimization

Please consider optimization tools for assets.

For PNGs, we recommend `optipng`, using the following command line:

```bash
optipng -zc1-9 -zm1-9 -zs0-3 -f0-5 *.png
```

Be careful about applying this aggressively. In particular, files in
the `assets/tests` directory should not be optimized.

The automatic generation tool will automatically apply optimization to
the assets it generates.

## Issues

Please file any issues in the [main flutter repo](https://github.com/flutter/flutter/issues/new).

## Origin of third-party content

* `/assets/audio/rooster.mp3`: CC0 Creative Commons, from [https://pixabay.com/sound-effects/rooster-crowing-7027/](https://pixabay.com/sound-effects/rooster-crowing-7027/)
* `/assets/videos/bee.mp4`: CC0 Creative Commons, from [https://pixabay.com/en/videos/honey-bee-insect-bee-flower-flying-211/](https://pixabay.com/en/videos/honey-bee-insect-bee-flower-flying-211/)
* `/assets/videos/butterfly.mp4`: CC0 Creative Commons, from [https://pixabay.com/en/videos/butterfly-flower-insect-nature-209/](https://pixabay.com/en/videos/butterfly-flower-insect-nature-209/)
* Also see the license information for [images used in the diagrams](packages/diagrams/assets/README.md)
