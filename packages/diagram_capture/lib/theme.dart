import 'package:flutter/material.dart';

/// The size of the viewport that diagrams are captured in.
const Size kDefaultDiagramViewportSize = Size(1280.0, 1024.0);

/// The default [MediaQuery] for diagrams.
///
/// This has no padding or insets, a devicePixelRatio of 1.0, and a
/// textScaleFactor of 1.0.
const MediaQueryData kDefaultMediaQuery = MediaQueryData(
  size: kDefaultDiagramViewportSize,
);

/// A [MaterialApp] with defaults that are appropriate for capturing diagrams.
///
/// By default we emulate the theme of an Android device in light mode, and
/// force the Roboto font.
class DiagramMaterialApp extends StatelessWidget {
  const DiagramMaterialApp({
    super.key,
    this.brightness = Brightness.light,
    this.platform = TargetPlatform.android,
    this.fontFamily = 'Roboto',
    this.primaryColor,
    this.colorScheme,
    this.textTheme,
    required this.home,
  });

  final Brightness? brightness;
  final TargetPlatform? platform;
  final String? fontFamily;
  final Color? primaryColor;
  final ColorScheme? colorScheme;
  final TextTheme? textTheme;
  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        platform: platform,
        fontFamily: fontFamily,
        primaryColor: primaryColor,
        colorScheme: colorScheme,
        textTheme: textTheme,
      ),
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      home: Builder(
        builder: (BuildContext context) {
          // The fallback text should also be roboto, like in unspecified_textstyle_material_app
          return DefaultTextStyle(
            style: DefaultTextStyle.of(context)
                .style
                .copyWith(fontFamily: fontFamily),
            child: home,
          );
        },
      ),
    );
  }
}
