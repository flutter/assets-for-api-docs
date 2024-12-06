// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:diagram_capture/diagram_capture.dart';
import 'package:diagrams/steps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../components/brightness_toggle.dart';
import '../components/diagram_ticker_mode.dart';
import '../logic/diagram_ticker_controller.dart';
import '../logic/subtree_widget_controller.dart';

class DiagramViewerPage extends StatefulWidget {
  const DiagramViewerPage({
    super.key,
    required this.step,
    required this.diagrams,
  });

  final DiagramStep step;
  final List<DiagramMetadata> diagrams;

  @override
  State<DiagramViewerPage> createState() => _DiagramViewerPageState();
}

class _DiagramViewerPageState extends State<DiagramViewerPage>
    with TickerProviderStateMixin {
  late final TabController tabController;
  List<DiagramMetadata> get diagrams => widget.diagrams;
  late final List<DiagramTickerController> controllers;
  late ModalRoute<void> route;
  late final Ticker ticker;
  final GlobalKey tabBarViewKey = GlobalKey();

  // Only allow the body of the viewer to receive pointer events from diagrams.
  late final SubtreeWidgetController widgetController = SubtreeWidgetController(
    WidgetsBinding.instance,
    tabBarViewKey,
  );

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: diagrams.length, vsync: this);

    tabController.addListener(onTabChange);

    controllers = <DiagramTickerController>[
      for (final DiagramMetadata diagram in diagrams)
        DiagramTickerController(diagram: diagram),
    ];

    ticker = createTicker((Duration elapsed) {
      // We have to wait until the route transition is over before starting the
      // diagram, otherwise it will interfere with simulated gestures.
      if (elapsed >= route.transitionDuration) {
        controllers.first.reset();
        controllers.first.select();
        ticker.stop();
      }
    });
    ticker.start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    route = ModalRoute.of<void>(context)!;
  }

  @override
  void dispose() {
    ticker.dispose();
    tabController.dispose();
    super.dispose();
  }

  int selectedIndex = 0;

  void onTabChange() {
    if (selectedIndex != tabController.index) {
      controllers[selectedIndex].deselect();
      selectedIndex = tabController.index;
    }

    if (tabController.indexIsChanging) {
      controllers[selectedIndex].deselect();
    } else {
      // Reset any controllers that have progress since they are now
      // off-screen.
      for (final DiagramTickerController controller in controllers) {
        if (controller.elapsed.value != Duration.zero) {
          controller.reset();
        }
      }

      controllers[selectedIndex].select();
    }
  }

  Widget buildControlBarWrapper(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                shape: const StadiumBorder(),
                color:
                    theme.brightness == Brightness.light
                        ? theme.primaryColor
                        : theme.colorScheme.surface,
                elevation: 4,
              ),
            ),
          ),
          buildControlBar(context),
        ],
      ),
    );
  }

  Widget buildControlBar(BuildContext context) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (BuildContext context, Widget? child) {
        final DiagramTickerController controller =
            controllers[tabController.index];
        return AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget? child) {
            return Container(
              height: 48.0,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: buildButtonRow(context, controller),
            );
          },
        );
      },
    );
  }

  Widget buildButtonRow(
    BuildContext context,
    DiagramTickerController controller,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (controller.ticking && !controller.animationDone)
          IconButton(
            onPressed: controller.pause,
            icon: const Icon(Icons.pause),
            color: Colors.white,
          )
        else
          IconButton(
            onPressed: controller.restart,
            icon: const Icon(Icons.restart_alt),
            color: Colors.white,
          ),
        Flexible(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: controller.showProgress ? 1 : 0,
              end: controller.showProgress ? 1 : 0,
            ),
            duration: const Duration(milliseconds: 150),
            curve: Curves.ease,
            builder: (BuildContext context, double value, Widget? child) {
              return Opacity(
                opacity: value,
                child: SizedBox(width: 300 * value, child: child),
              );
            },
            child: SliderTheme(
              data: SliderThemeData(disabledThumbColor: Colors.grey.shade200),
              child: AnimatedBuilder(
                animation: controller.elapsed,
                builder: (BuildContext context, Widget? child) {
                  return Slider(value: controller.progress, onChanged: null);
                },
              ),
            ),
          ),
        ),
        const BrightnessToggleButton(color: Colors.white),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget tabBarView = TabBarView(
      key: tabBarViewKey,
      // The diagram has a big shadow that looks nicer without a clip.
      clipBehavior: Clip.none,
      controller: tabController,
      children: <Widget>[
        for (int index = 0; index < tabController.length; index++)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 30,
                    blurStyle: BlurStyle.outer,
                  ),
                ],
                borderRadius: BorderRadius.circular(2),
              ),
              child: DiagramTickerMode(
                controller: controllers[index],
                child: widget.diagrams[index],
              ),
            ),
          ),
      ],
    );

    final Widget body = Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 48),
          child: DiagramWidgetController(
            controller: widgetController,
            child: tabBarView,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: buildControlBarWrapper(context),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 1050) {
          // Wide layouts: No app bar, instead diagrams are selected with a
          // dedicated drawer.
          return Scaffold(
            body: Row(
              children: <Widget>[
                DiagramSwitchDrawer(
                  step: widget.step,
                  diagrams: widget.diagrams,
                  onChanged: (int index) {
                    tabController.animateTo(index);
                  },
                ),
                Expanded(
                  child: ClipRect(child: SafeArea(left: false, child: body)),
                ),
              ],
            ),
          );
        } else {
          // Narrow layouts: DropdownButton in the AppBar for selecting
          // diagrams.
          return Scaffold(
            appBar: DiagramSwitchAppBar(
              tabController: tabController,
              diagrams: diagrams,
            ),
            body: Column(
              children: <Widget>[
                Expanded(child: SafeArea(left: false, child: body)),
              ],
            ),
          );
        }
      },
    );
  }
}

class DiagramSwitchAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const DiagramSwitchAppBar({
    super.key,
    required this.tabController,
    required this.diagrams,
  });

  final TabController tabController;
  final List<DiagramMetadata> diagrams;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme primaryTextTheme = theme.primaryTextTheme;
    final TextStyle textStyle = primaryTextTheme.titleLarge!;
    return AnimatedBuilder(
      animation: tabController,
      builder: (BuildContext context, Widget? child) {
        return AppBar(
          title: DropdownButton<int>(
            value: tabController.index,
            onChanged: (int? i) => tabController.animateTo(i!),
            isExpanded: true,
            style: textStyle,
            dropdownColor: theme.primaryColor,
            iconEnabledColor: textStyle.color,
            items: <DropdownMenuItem<int>>[
              for (int i = 0; i < diagrams.length; i++)
                DropdownMenuItem<int>(
                  value: i,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(diagrams[i].name),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class DiagramSwitchDrawer extends StatelessWidget {
  const DiagramSwitchDrawer({
    super.key,
    required this.step,
    required this.diagrams,
    required this.onChanged,
  });

  final DiagramStep step;
  final List<DiagramMetadata> diagrams;
  final ValueChanged<int> onChanged;

  Widget buildChild(BuildContext context, int index) {
    final DiagramMetadata diagram = diagrams[index];
    return ListTile(title: Text(diagram.name), onTap: () => onChanged(index));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16,
      child: SafeArea(
        right: false,
        child: SizedBox(
          width: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppBar(elevation: 0, title: Text('${step.runtimeType}')),
              Expanded(
                child: ListView.builder(
                  itemBuilder: buildChild,
                  itemCount: diagrams.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
