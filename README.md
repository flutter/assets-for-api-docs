# assets-for-api-docs

This repo is used to host and serve static assets in support of
docs.flutter.io.

Assets committed to this repo and pushed to GitHub are immediately
available for linking and reference.

## URL structure

Reference the assets with this URL structure:

`https://flutter.github.io/assets-for-api-docs/<library>/<asset>`

For example, an image named `app_bar.png` about `AppBar` from the
material library would go in the `material/` directory and be at
`https://flutter.github.io/assets-for-api-docs/material/app_bar.png`.

## Optimization

Please consider optimization tools for assets.

For PNGs, we recommend `optipng`.

## Generation

Please consider generating images from some sort of source code rather
than by hand. For example, have a little Flutter program that
generates the PNGs so that we can easily re-run the program and
regenerate the images if we want to e.g. change the resolution or
adjust the text slightly. For an example, see <dart-ui/tile_mode.dart>.
