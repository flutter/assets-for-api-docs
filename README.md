# assets-for-api-docs

This repo is used to host and serve static assets in support of
[docs.flutter.io](https://docs.flutter.io), as well as some manual tests that use
specially-crafted graphics.

Assets committed to this repo and pushed to GitHub are immediately
available for linking and reference.

## URL structure

Reference the assets with this URL structure:

`https://flutter.github.io/assets-for-api-docs/assets/<library>/<asset>`

For example, an image named `app_bar.png` about `AppBar` from the
material library would go in the `assets/material/` directory and be at
`https://flutter.github.io/assets-for-api-docs/assets/material/app_bar.png`.

All asset files should be under the `assets` directory in an appropriate
subdirectory.

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

## Generation

See the [documentation for the generate.dart script in the `diagrams`
directory](packages/diagrams/README.md), in conjunction with the
[`generate.dart`](./bin/generate.dart) script. It will regenerate almost all of
existing assets using the Flutter version you have installed. Feel free
to add more modules in the `diagrams` package to generate new assets.

### Prerequisites

In order for the `generate.dart` script to work, it needs several supporting
apps.

To optimize PNG files, it needs `optipng`, which is available for macOS via Homebrew, and Linux via
apt-get.

To convert animations into mp4 files, it needs `ffmpeg`, available for macOS via Homebrew and Linux
via apt-get.

The generator currently only supports running on an Android runtime. An Android
device or emulator must be running before invoking the `generate.dart` script.

The Android `adb` command and the `flutter` command need to both be available and in a directory in
the `PATH` environment variable. Be sure it is the same one that is running as a server (which is
often started by your IDE, so use the same `adb` the IDE is running).

The `generate.dart` script only works on macOS and Linux, because of the supporting apps it needs to
run.

## Origin of third-party content

* `/assets/videos/bee.mp4`: CC0 Creative Commons, from [https://pixabay.com/en/videos/honey-bee-insect-bee-flower-flying-211/](https://pixabay.com/en/videos/honey-bee-insect-bee-flower-flying-211/)
* `/assets/videos/butterfly.mp4`: CC0 Creative Commons, from [https://pixabay.com/en/videos/butterfly-flower-insect-nature-209/](https://pixabay.com/en/videos/butterfly-flower-insect-nature-209/)
* Also see the license information for [images used in the diagrams](packages/diagrams/assets/README.md)
