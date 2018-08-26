## Diagrams

Library for drawing API documentation diagram assets.

## Usage

To add a diagram or group of related diagrams to the package, create a new DiagramStep subclass,
implementing the `Future<List<File>> generateDiagrams()` method to generate the diagrams and return
the output PNG files and JSON metadata (for animations) on the device. Then, add an instance of your
new DiagramStep in the `List<DiagramStep> steps` list in
`utils/diagram_generator/lib/main.dart`.

To help with generation of the images, use the `DiagramController` class from the `diagram_capture`
package in `packages/diagram_capture`.

There are examples for using both of these classes in this directory, and in the example directory
of the `diagram_capture` package.
