import 'package:flutter/material.dart';

import '../main.dart';

class BrightnessToggleButton extends StatelessWidget {
  const BrightnessToggleButton({
    super.key,
    this.color,
  });

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        DiagramViewerApp.of(context).toggleBrightness();
      },
      icon: Icon(
        Theme.of(context).brightness == Brightness.light
            ? Icons.dark_mode_rounded
            : Icons.light_mode_rounded,
      ),
      color: color,
    );
  }
}
