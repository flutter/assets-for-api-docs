# Source for generating API docs.

This directory contains source code for generating the images for the API docs.

## Guiding Principles

The idea here is to just have a way to regenerate images for the API docs when
the rendering or other aspects of the output change. It should be something that
doesn't require a lot of work to regenerate. For some assets, a script may be
necessary. It should be well documented here what the prerequisites and
limitations of the script are (what platform it should be run on, etc).

# The Generators

There is a script `generate.dart` that will generate all of the asset images from
the generator Dart files in the subdirectories.

For usage, run `dart ./generate.dart --help`.

### Prerequisites

 - ImageMagick (`brew install imagemagick` on MacOS, `apt-get install imagemagick` on Ubuntu).
 - optipng (`brew install optipng` on MacOS, `apt-get install optipng` on Ubuntu).

You should also set up a symlink `analysis_options.yaml` that points
to your Flutter repository, as follows:

```bash
ln -s ../../flutter/analysis_options.yaml analysis_options.yaml
```

### Adding new code

To add a new asset generator, add your generator's `.dart` file under the appropriate
section, and add it to the list of overall generators in the generate.dart script,
under either the vertical or horizontal list, depending upon which aspect your
generator needs.
