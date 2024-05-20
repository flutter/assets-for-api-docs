// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../diagrams.dart';

const Duration _kOverallAnimationDuration = Duration(seconds: 6);
const Duration _kAnimationDuration = Duration(seconds: 2);

class AnimatedAlignDiagram extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const AnimatedAlignDiagram({super.key})
      : super(duration: _kOverallAnimationDuration);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Widget buildImplicitAnimation(BuildContext context, bool selected) {
    return Center(
      child: ImplicitAnimationDiagramTapper(
        child: AnimatedAlign(
          alignment:
              selected ? Alignment.center : AlignmentDirectional.bottomStart,
          duration: _kAnimationDuration,
          curve: curve,
          child: const SampleWidget(small: true),
        ),
      ),
    );
  }
}

class AnimatedContainerDiagram
    extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const AnimatedContainerDiagram({super.key})
      : super(duration: _kOverallAnimationDuration);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Widget buildImplicitAnimation(BuildContext context, bool selected) {
    return Center(
      child: ImplicitAnimationDiagramTapper(
        child: AnimatedContainer(
          width: selected ? 200.0 : 100.0,
          height: selected ? 100.0 : 200.0,
          color: selected ? Colors.red : Colors.blue,
          alignment:
              selected ? Alignment.center : AlignmentDirectional.topCenter,
          duration: _kAnimationDuration,
          curve: curve,
          child: const SampleWidget(small: true),
        ),
      ),
    );
  }
}

class AnimatedDefaultTextStyleDiagram
    extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const AnimatedDefaultTextStyleDiagram({super.key})
      : super(duration: _kOverallAnimationDuration);

  @override
  Curve get curve => Curves.elasticInOut;

  @override
  Widget buildImplicitAnimation(BuildContext context, bool selected) {
    final TextStyle selectedStyle =
        Theme.of(context).textTheme.headlineMedium!.copyWith(
              color: Colors.red,
              fontSize: 50.0,
              fontWeight: FontWeight.w100,
            );
    final TextStyle unselectedStyle = selectedStyle.copyWith(
      color: Colors.blue,
      fontSize: 50.0,
      fontWeight: FontWeight.w900,
    );

    return Center(
      child: ImplicitAnimationDiagramTapper(
        child: AnimatedDefaultTextStyle(
          style: selected ? selectedStyle : unselectedStyle,
          duration: _kAnimationDuration,
          textAlign: TextAlign.center,
          curve: curve,
          child: const Text('Flutter'),
        ),
      ),
    );
  }
}

class AnimatedOpacityDiagram
    extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const AnimatedOpacityDiagram({super.key})
      : super(duration: _kOverallAnimationDuration);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Widget buildImplicitAnimation(BuildContext context, bool selected) {
    return Center(
      child: ImplicitAnimationDiagramTapper(
        child: AnimatedOpacity(
          opacity: selected ? 1.0 : 0.1,
          duration: _kAnimationDuration,
          curve: curve,
          child: const SampleWidget(),
        ),
      ),
    );
  }
}

class AnimatedPaddingDiagram
    extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const AnimatedPaddingDiagram({super.key})
      : super(duration: _kOverallAnimationDuration);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Widget buildImplicitAnimation(BuildContext context, bool selected) {
    return Center(
      child: ImplicitAnimationDiagramTapper(
        child: AnimatedPadding(
          padding: selected
              ? const EdgeInsets.symmetric(vertical: 80.0)
              : const EdgeInsets.symmetric(horizontal: 80.0),
          duration: _kAnimationDuration,
          curve: curve,
          child: Container(color: Colors.blue),
        ),
      ),
    );
  }
}

class AnimatedPhysicalModelDiagram
    extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const AnimatedPhysicalModelDiagram({super.key})
      : super(duration: _kOverallAnimationDuration);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Widget buildImplicitAnimation(BuildContext context, bool selected) {
    const Radius selectedRadius = Radius.circular(75.0);
    const Radius unselectedRadius = Radius.circular(5.0);
    const BorderRadius selectedBorder = BorderRadius.only(
      topLeft: selectedRadius,
      topRight: selectedRadius,
      bottomLeft: selectedRadius,
    );
    const BorderRadius unselectedBorder = BorderRadius.all(unselectedRadius);
    return Center(
      child: Container(
        alignment: Alignment.center,
        width: 150.0,
        height: 150.0,
        child: ImplicitAnimationDiagramTapper(
          child: AnimatedPhysicalModel(
            color: Colors.blue,
            elevation: selected ? 20.0 : 0.0,
            shadowColor: Colors.grey,
            borderRadius: selected ? selectedBorder : unselectedBorder,
            duration: _kAnimationDuration,
            curve: curve,
            child: Container(color: Colors.blue),
          ),
        ),
      ),
    );
  }
}

class AnimatedPositionedDiagram
    extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const AnimatedPositionedDiagram({super.key})
      : super(duration: _kOverallAnimationDuration);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Widget buildImplicitAnimation(BuildContext context, bool selected) {
    return Center(
      child: Stack(
        children: <Widget>[
          const SizedBox(width: 250.0, height: 250.0),
          ImplicitAnimationDiagramTapper(
            child: AnimatedPositioned(
              width: selected ? 150.0 : 50.0,
              height: selected ? 50.0 : 150.0,
              top: selected ? 20.0 : 80.0,
              left: selected ? 0.0 : 80.0,
              duration: _kAnimationDuration,
              curve: curve,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedPositionedDirectionalDiagram
    extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const AnimatedPositionedDirectionalDiagram({super.key})
      : super(duration: _kOverallAnimationDuration);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Widget buildImplicitAnimation(BuildContext context, bool selected) {
    return Center(
      child: Stack(
        children: <Widget>[
          const SizedBox(width: 250.0, height: 250.0),
          Directionality(
            textDirection: TextDirection.rtl,
            child: ImplicitAnimationDiagramTapper(
              child: AnimatedPositionedDirectional(
                width: selected ? 150.0 : 50.0,
                height: selected ? 50.0 : 150.0,
                top: selected ? 20.0 : 80.0,
                start: selected ? 0.0 : 10.0,
                duration: _kAnimationDuration,
                curve: curve,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.blue,
                  child: const Text('من اليمين إلى اليسار'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedThemeDiagram extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const AnimatedThemeDiagram({super.key})
      : super(duration: _kOverallAnimationDuration);

  @override
  Curve get curve => Curves.elasticInOut;

  @override
  Widget buildImplicitAnimation(BuildContext context, bool selected) {
    final ThemeData unselectedTheme = Theme.of(context);
    final ChipThemeData selectedChipTheme = unselectedTheme.chipTheme.copyWith(
      padding: const EdgeInsets.all(20.0),
    );
    final ThemeData selectedTheme = unselectedTheme.copyWith(
      chipTheme: selectedChipTheme,
    );

    return Center(
      child: ImplicitAnimationDiagramTapper(
        child: AnimatedTheme(
          data: selected ? selectedTheme : unselectedTheme,
          duration: _kAnimationDuration,
          curve: curve,
          child: const ChoiceChip(
            selected: false,
            label: Text('AnimatedTheme'),
          ),
        ),
      ),
    );
  }
}

class WindowPaddingDiagram extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const WindowPaddingDiagram({super.key})
      : super(duration: _kOverallAnimationDuration);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Size get size => const Size(400.0, 800.0);

  @override
  Widget buildImplicitAnimation(BuildContext context, bool selected) {
    return ImplicitAnimationDiagramTapper(
      child: Stack(
        children: <Widget>[
          SizedBox(
            height: 45,
            child: Container(
              color: Colors.red,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: SizedBox(
              height: 30,
              child: Container(
                color: Colors.red,
              ),
            ),
          ),
          // "Notch"
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
              ),
              child: Container(
                  color: Colors.black, width: size.width * .6, height: 40),
            ),
          ),

          // "Keyboard"
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: SizedBox(
              height: selected ? size.height * .4 : 0,
              width: size.width,
              child: Container(
                color: Colors.grey,
                child: const Center(
                  child: Text(
                    'KEYBOARD',
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // "Bottom button"
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: SizedBox(
              height: 20,
              child: Align(
                alignment: AlignmentDirectional.topCenter,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  child: Container(
                    color: Colors.black,
                    height: 10,
                    width: size.width * .4,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.center,
            child: Text(
              '${selected ? 'Bottom padding absorbed by insets' : 'Bottom padding equals viewPadding'}\n\n'
              'window.viewInsets.bottom: ${selected ? size.height * .4 : 0}\n'
              'window.viewPadding.bottom: 40\n'
              'window.padding.bottom: ${selected ? 0 : 40}\n',
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class ImplicitAnimationDiagramTapper extends StatefulWidget {
  const ImplicitAnimationDiagramTapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ImplicitAnimationDiagramTapper> createState() =>
      _ImplicitAnimationDiagramTapperState();
}

class _ImplicitAnimationDiagramTapperState
    extends State<ImplicitAnimationDiagramTapper>
    with TickerProviderStateMixin, LockstepStateMixin {
  Future<void> startAnimation() async {
    // Wait for the tree to finish building before attempting to find our
    // RenderObject.
    await Future<void>.delayed(Duration.zero);

    final WidgetController controller = DiagramWidgetController.of(context);
    final RenderBox target = context.findRenderObject()! as RenderBox;
    Offset targetOffset = target.localToGlobal(target.size.center(Offset.zero));
    await controller.tapAt(targetOffset);

    await waitLockstep(const Duration(seconds: 3));

    targetOffset = target.localToGlobal(target.size.center(Offset.zero));
    await controller.tapAt(targetOffset);
  }

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class ImplicitAnimationDiagramStep extends DiagramStep {
  @override
  final String category = 'widgets';

  @override
  Future<List<DiagramMetadata>> get diagrams async {
    return const <DiagramMetadata>[
      AnimatedAlignDiagram(),
      AnimatedContainerDiagram(),
      AnimatedDefaultTextStyleDiagram(),
      AnimatedOpacityDiagram(),
      AnimatedPaddingDiagram(),
      AnimatedPhysicalModelDiagram(),
      AnimatedPositionedDiagram(),
      AnimatedPositionedDirectionalDiagram(),
      AnimatedThemeDiagram(),
      WindowPaddingDiagram(),
    ];
  }
}
