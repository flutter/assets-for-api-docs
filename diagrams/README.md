## Diagrams

Main app for building API documentation diagram assets.

## Usage

To add a diagram or group of related diagrams to the app, create a new DiagramStep subclass,
implementing the `Future<List<File>> generateDiagrams()` method to generate the diagrams and return
the output PNG files and JSON metadata (for animations) on the device. Then, add an instance of your
new DiagramStep in the `List<DiagramStep> steps` list in `main.dart`.

To help with generation of the images, use the `DiagramController` class from the `diagram_capture`
package in `packages/diagram_capture`.

There are examples for using both of these classes in this directory, and in the example directory
of the `diagram_capture` package.

## Prerequisites

In order for the `generate.dart` script to work, it needs several supporting
apps.

To optimize PNG files, it needs `optipng`, which is available for macOS via Homebrew, and Linux via
apt-get.

To convert animations into mp4 files, it needs `ffmpeg`, available for macOS via Homebrew and Linux
via apt-get.

The Android `adb` command and the `flutter` command need to both be available and in a directory in
the `PATH` environment variable.

The `generate.dart` script only works on macOS and Linux, because of the supporting apps it needs to
run.