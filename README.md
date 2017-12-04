# assets-for-api-docs

This repo is used to host and serve static assets in support of
docs.flutter.io as well as some manual tests that use
specially-crafted graphics.

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

For PNGs, we recommend `optipng`, using the following command line:

```bash
optipng -zc1-9 -zm1-9 -zs0-3 -f0-5 *.png
```

Be careful about applying this aggressively. In particular, files in
the `tests` directory should not be optimised.

## Generation

See the [documentation for the generate.dart script in the src
directory](src/README.md), which will will generate a number of
existing assets.  Feel free to add more programs there to generate
new assets.

## Origin of third-party content

* `/videos/bee.mp4`: CC0 Creative Commons, from [https://pixabay.com/en/videos/honey-bee-insect-bee-flower-flying-211/](https://pixabay.com/en/videos/honey-bee-insect-bee-flower-flying-211/)
* `/videos/butterfly.mp4`: CC0 Creative Commons, from [https://pixabay.com/en/videos/butterfly-flower-insect-nature-209/](https://pixabay.com/en/videos/butterfly-flower-insect-nature-209/)
