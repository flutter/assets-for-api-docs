
## Sampler

This repo contains a package and a Flutter app meant to help Flutter framework
developers (the developers that work on the framework itself) create sample
applications for the [API documentation](https://api.flutter.dev) for Flutter.

To run the app, run the appropriate executable for your platform, under the
[bin](bin) directory.

This will run a Flutter app that will automatically load the list of files in
the framework, and let you pick one.

If the the `flutter` command is on your `PATH`, the app should be able to find the
repo automatically, but if not, or if you'd rather specify the location yourself,
you can either set the `FLUTTER_ROOT` environment variable, or supply the
`--flutter-root` argument to the executable with the absolute path to the
flutter repo you wish to use.

If you want to add a new sample, add a blank insertion into a dartdoc, like
this, before you select the file in the app:

```
  /// {@tool dartdoc --template=material_scaffold}
  /// {@end-tool}
```

Also before you select a file in the app, if you want to change the template you
are inserting into, change it in the original dartdoc comments before you
extract.

When the app starts, type part of the name of the file in which you would like
to edit a sample, and it should autocomplete.  Select the file, and it will show
you a list of the available samples to edit.

Once you select a sample with the `SELECT` button, it will move to a detail page
where you can extract that sample into a temporary project, and open the project
in an IDE or editor.

Now you can extract the sample with the `EXTRACT SAMPLE` button, it will create
a temporary project and prepare it for editing. Be **sure** you have your
Flutter git repo in the correct branch/state for editing the files you want to
edit.

Once you have extracted the sample, you can copy the path to its main and open
that in your editor, or use the `OPEN IN VS CODE` or `OPEN IN INTELLIJ` buttons
to open then project in an IDE.

Now you can edit that sample.  Be careful to only edit the sections inside
the section markers: any editing occurring outside the section markers will
be lost when the code is reinserted. If you need to make a change to code that
is not part of a section, you will have to edit the template, or create a new
template, instead.

Here's what the section markers look like:

```
//********************************************************************
//* ▼▼▼▼▼▼▼▼ code ▼▼▼▼▼▼▼▼ (do not modify or remove section marker)

//[ code goes here ...]

//* ▲▲▲▲▲▲▲▲ code ▲▲▲▲▲▲▲▲ (do not modify or remove section marker)
//********************************************************************
```

After you're done with your modifications to the sample, save the code to disk,
and then go back to the `sampler` app.  You can then click the `REINSERT` button
to take the edited sample and it will be placed back into the documentation
comments in the original framework file. You can open that file from the
`sampler` app with the appropriate buttons, or copy/paste the path into your
editor.

## Missing features

This is still a work in progress, so if you find something missing, either [send
me a PR](https://github.com/gspencergoog/sampler/pulls), [open an
issue](https://github.com/gspencergoog/sampler/issues/new), or just message me.

Some features I'm planning to add:
 - Creating a new sample on an element in a file.
 - Change the template that a sample is inserted into and re-export.
 - Persistent settings for:
    - The location for your editor/IDE
    - The location of the Flutter repo to use
    - The location for the temporary projects
 - Cleaning up the temporary projects after re-insertion.
 - More tests!
 - Converting Flutter's CI sample analysis and snippet tools to use the snippets
   package herein (maybe).

## Open Questions

 - How best to distribute to the team? Prebuilt binaries seem...clunky, and
   building it yourself even more so.
 