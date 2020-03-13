// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'animation_diagram.dart';
import 'diagram_step.dart';

final GlobalKey _transitionKey = new GlobalKey();

const Duration _kOverallAnimationDuration = Duration(seconds: 6);
const Duration _kAnimationDuration = Duration(seconds: 2);
const double _kAnimationFrameRate = 60.0;

class ImplicitAnimationDiagramStep extends DiagramStep<ImplicitAnimationDiagram<dynamic>> {
  ImplicitAnimationDiagramStep(DiagramController controller) : super(controller) {
    _diagrams.add(const AnimatedAlignDiagram());
    _diagrams.add(const AnimatedContainerDiagram());
    _diagrams.add(const AnimatedDefaultTextStyleDiagram());
    _diagrams.add(const AnimatedOpacityDiagram());
    _diagrams.add(const AnimatedPaddingDiagram());
    _diagrams.add(const AnimatedPhysicalModelDiagram());
    _diagrams.add(const AnimatedPositionedDiagram());
    _diagrams.add(const AnimatedPositionedDirectionalDiagram());
    _diagrams.add(const AnimatedThemeDiagram());
    _diagrams.add(const WindowPaddingDiagram());
  }

  final List<ImplicitAnimationDiagram<dynamic>> _diagrams = <ImplicitAnimationDiagram<dynamic>>[];

  @override
  final String category = 'widgets';

  @override
  Future<List<ImplicitAnimationDiagram<dynamic>>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(ImplicitAnimationDiagram<dynamic> diagram) async {
    controller.builder = (BuildContext context) => diagram;

    final Map<Duration, DiagramKeyframe> keyframes = <Duration, DiagramKeyframe>{
      Duration.zero: (Duration now) async {
        final RenderBox target = _transitionKey.currentContext.findRenderObject();
        final Offset targetOffset = target.localToGlobal(target.size.center(Offset.zero));
        final TestGesture gesture = await controller.startGesture(targetOffset);
        await gesture.up();
      },
      const Duration(seconds: 3): (Duration now) async {
        final RenderBox target = _transitionKey.currentContext.findRenderObject();
        final Offset targetOffset = target.localToGlobal(target.size.center(Offset.zero));
        final TestGesture gesture = await controller.startGesture(targetOffset);
        await gesture.up();
      },
    };

    final File result = await controller.drawAnimatedDiagramToFiles(
      end: _kOverallAnimationDuration,
      frameRate: _kAnimationFrameRate,
      name: diagram.name,
      category: category,
      keyframes: keyframes,
    );
    return result;
  }
}

class AnimatedAlignDiagram extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const AnimatedAlignDiagram({Key key}) : super(key: key);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Widget buildImplicitAnimation(BuildContext context, bool selected) {
    return new Center(
      child: new AnimatedAlign(
        alignment: selected ? Alignment.center : AlignmentDirectional.bottomStart,
        duration: _kAnimationDuration,
        curve: curve,
        key: _transitionKey,
        child: const SampleWidget(small: true),
      ),
    );
  }
}

class AnimatedContainerDiagram extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const AnimatedContainerDiagram({Key key}) : super(key: key);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Widget buildImplicitAnimation(BuildContext context, bool selected) {
    return new Center(
      child: new AnimatedContainer(
        width: selected ? 200.0 : 100.0,
        height: selected ? 100.0 : 200.0,
        color: selected ? Colors.red : Colors.blue,
        alignment: selected ? Alignment.center : AlignmentDirectional.topCenter,
        duration: _kAnimationDuration,
        curve: curve,
        key: _transitionKey,
        child: const SampleWidget(small: true),
      ),
    );
  }
}

class AnimatedDefaultTextStyleDiagram extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const AnimatedDefaultTextStyleDiagram({Key key}) : super(key: key);

  @override
  Curve get curve => Curves.elasticInOut;

  @override
  Widget buildImplicitAnimation(BuildContext context, bool selected) {
    final TextStyle selectedStyle = Theme.of(context).textTheme.headline4.copyWith(
          color: Colors.red,
          fontSize: 60.0,
          fontWeight: FontWeight.w100,
        );
    final TextStyle unselectedStyle = selectedStyle.copyWith(
      color: Colors.blue,
      fontSize: 60.0,
      fontWeight: FontWeight.w900,
    );

    return new Center(
      child: new AnimatedDefaultTextStyle(
        style: selected ? selectedStyle : unselectedStyle,
        duration: _kAnimationDuration,
        textAlign: TextAlign.center,
        curve: curve,
        key: _transitionKey,
        child: const Text('Flutter'),
      ),
    );
  }
}

class AnimatedOpacityDiagram extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const AnimatedOpacityDiagram({Key key}) : super(key: key);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Widget buildImplicitAnimation(BuildContext context, bool selected) {
    return new Center(
      child: new AnimatedOpacity(
        opacity: selected ? 1.0 : 0.1,
        duration: _kAnimationDuration,
        curve: curve,
        key: _transitionKey,
        child: const SampleWidget(),
      ),
    );
  }
}

class AnimatedPaddingDiagram extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const AnimatedPaddingDiagram({Key key}) : super(key: key);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Widget buildImplicitAnimation(BuildContext context, bool selected) {
    return new Center(
      child: new AnimatedPadding(
        padding: selected ? const EdgeInsets.symmetric(vertical: 80.0) : const EdgeInsets.symmetric(horizontal: 80.0),
        duration: _kAnimationDuration,
        curve: curve,
        key: _transitionKey,
        child: new Container(color: Colors.blue),
      ),
    );
  }
}

class AnimatedPhysicalModelDiagram extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const AnimatedPhysicalModelDiagram({Key key}) : super(key: key);

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
      child: new Container(
        alignment: Alignment.center,
        width: 150.0,
        height: 150.0,
        child: new AnimatedPhysicalModel(
          color: Colors.blue,
          elevation: selected ? 20.0 : 0.0,
          shadowColor: Colors.grey,
          borderRadius: selected ? selectedBorder : unselectedBorder,
          shape: BoxShape.rectangle,
          duration: _kAnimationDuration,
          curve: curve,
          key: _transitionKey,
          child: new Container(color: Colors.blue),
        ),
      ),
    );
  }
}

class AnimatedPositionedDiagram extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const AnimatedPositionedDiagram({Key key}) : super(key: key);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Widget buildImplicitAnimation(BuildContext context, bool selected) {
    return new Center(
      child: new Stack(
        children: <Widget>[
          new Container(width: 250.0, height: 250.0),
          new AnimatedPositioned(
            key: _transitionKey,
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
        ],
      ),
    );
  }
}

class AnimatedPositionedDirectionalDiagram extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const AnimatedPositionedDirectionalDiagram({Key key}) : super(key: key);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Widget buildImplicitAnimation(BuildContext context, bool selected) {
    return new Center(
      child: new Stack(
        children: <Widget>[
          new Container(width: 250.0, height: 250.0),
          new Directionality(
            textDirection: TextDirection.rtl,
            child: new AnimatedPositionedDirectional(
              key: _transitionKey,
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
        ],
      ),
    );
  }
}

class AnimatedThemeDiagram extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const AnimatedThemeDiagram({Key key}) : super(key: key);

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

    return new Center(
      child: new AnimatedTheme(
        data: selected ? selectedTheme : unselectedTheme,
        duration: _kAnimationDuration,
        curve: curve,
        key: _transitionKey,
        child: const ChoiceChip(
          selected: false,
          label: Text('AnimatedTheme'),
        ),
      ),
    );
  }
}

class WindowPaddingDiagram extends ImplicitAnimationDiagram<AlignmentGeometry> {
  const WindowPaddingDiagram({Key key}) : super(key: key);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Size get size => const Size(400.0, 800.0);

  @override
  Widget buildImplicitAnimation(BuildContext context, bool selected) {
    return Stack(
      key: _transitionKey,
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
            child: Container(color: Colors.black, width: size.width * .6, height: 40),
          ),
        ),

        // "Keyboard"
        Align(
          alignment: AlignmentDirectional.bottomCenter,
          child: Container(
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
          child: Container(
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
    );
  }
}
