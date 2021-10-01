## Sampler App

This directory contains a Flutter app meant to help Flutter framework developers
(the developers that work on the framework itself) create sample applications
for the [API documentation](https://api.flutter.dev) for Flutter.

The easiest way to run the app, is to do this:

```
% dart pub global activate sampler  # Just need to do this the first time.
% dart pub global run sampler
```

Which will build and run the app in release mode on your platform. The
application only runs on Linux, macOS, and Windows (mobile OSs don't have access
to the Flutter repo, and who would want to code there anyhow!). The first time
you run it, it will build the Flutter app, and will run that app thereafter.

This Flutter app that will automatically load the list of files in the
framework, and let you pick one.

If the the `flutter` command is on your `PATH`, the app should be able to find
the repo automatically, but if not, or if you'd rather specify the location
yourself, you can either set the `FLUTTER_ROOT` environment variable, or supply
the `--flutter-root` argument to the executable with the absolute path to the
flutter repo you wish to use.

Be *sure* you have your Flutter git repo in the correct branch/state for editing
the files you want to edit.

```
Hint: Before you select a file in the app, if you want to change the template
you are inserting into, change it in the original dartdoc comments before you
extract.
```

When the app starts, type part of the name of the framework file in which the
sample would like to edit resides, and it will autocomplete. Select the file,
and it will show you a list of the available elements to edit the sample on, or
to add a new sample to. The app monitors the filesystem, so if the selected
framework file changes, it will re-parse the file.

You can filter which elements are shown by unchecking the type of elements you
wish to filter out, and you can sort alphabetically, or by line number.

If you want to add a new sample, click the "ADD SAMPLE" button next to the
element you want to add the sample to. The sample will be added at the end of
the documentation comment, just before the "See also:" section, if any. The
inserted sample will be immediately added to the actual framework file, and
`sampler` will select the new sample for you to edit.

Once you add a new sample, or select a sample with the `SELECT` button, it will
move to a sample detail page where you can extract that sample into a temporary
project, and open the project in an IDE or editor.

Once on the sample page, you can extract the sample with the `EXTRACT SAMPLE`
button. It will create a temporary project and prepare it for editing.

Once you have extracted the sample, you can copy the path to its main and open
that in your editor, or use the `OPEN IN VS CODE` or `OPEN IN INTELLIJ` buttons
to open then project in an IDE.

Now edit the selected sample. Be careful to only edit the sections inside the
section markers: any editing occurring outside the section markers will be lost
when the code is reinserted. If you mangle the section markers themselves, it
probably will fail to re-insert. If you need to make a change to code that is
not part of a section, you will have to edit the template, or create a new
template instead.

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
to place edited sample back into the documentation comments in the original
framework file. You can open that file from the `sampler` app with the
appropriate buttons, or copy/paste the path into your editor.

## Missing features

This is still a work in progress, so if you find something missing, either [send
me a PR](https://github.com/gspencergoog/sampler/pulls), [open an
issue](https://github.com/gspencergoog/sampler/issues/new), or just message me.

Some features I'm planning to add:
 - Change the template that a sample is inserted into and re-export.
 - Persistent settings for:
    - The location for your editor/IDE
    - The location of the Flutter repo to use
    - The location for the temporary projects
 - Cleaning up the temporary projects after re-insertion.
 - More tests!
