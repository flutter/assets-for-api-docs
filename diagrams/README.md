## Diagrams

Main app for building API documentation diagram assets.

## Usage

To add a diagram or group of related diagrams to the app, create a new DiagramStep subclass,
implementing the `Future<List<File>> generateDiagrams()` method to generate the diagrams and return
the output PNG files on the device. Then, add an instance in the `List<DiagramStep> steps` list in
`main.dart`.

To help with generation of the images, use the `DiagramController` class from the `diagram` package
in `packages/diagram`.

There are examples for using both of these classes in this directory, and in the example director of
the `diagram` package.
