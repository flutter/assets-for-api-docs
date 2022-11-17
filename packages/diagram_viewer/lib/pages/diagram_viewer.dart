import 'package:diagrams/steps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../components/brightness_toggle.dart';
import '../components/diagram_ticker_mode.dart';
import '../logic/diagram_ticker_controller.dart';

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

  @override
  void initState() {
    super.initState();

    tabController = TabController(
      length: diagrams.length,
      vsync: this,
    );

    tabController.addListener(onTabChange);

    controllers = <DiagramTickerController>[
      for (final DiagramMetadata diagram in diagrams)
        DiagramTickerController(
          diagram: diagram,
        ),
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
                color: theme.brightness == Brightness.light
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
                child: SizedBox(
                  width: 300 * value,
                  child: child,
                ),
              );
            },
            child: SliderTheme(
              data: SliderThemeData(
                disabledThumbColor: Colors.grey.shade200,
              ),
              child: AnimatedBuilder(
                animation: controller.elapsed,
                builder: (BuildContext context, Widget? child) {
                  return Slider(
                    value: controller.progress,
                    onChanged: null,
                  );
                },
              ),
            ),
          ),
        ),
        const BrightnessToggleButton(
          color: Colors.white,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget tabBarView = TabBarView(
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
          )
      ],
    );

    final Widget body = Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: 8,
            top: 8,
            right: 8,
            bottom: 48,
          ),
          child: tabBarView,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: buildControlBarWrapper(context),
        ),
      ],
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth >= 1050) {
            return Row(
              children: <Widget>[
                DiagramSwitchDrawer(
                  step: widget.step,
                  diagrams: widget.diagrams,
                  onChanged: (int index) {
                    tabController.animateTo(index);
                  },
                ),
                Expanded(
                  child: ClipRect(
                    child: SafeArea(
                      left: false,
                      child: body,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: <Widget>[
                Expanded(
                  child: SafeArea(
                    left: false,
                    child: body,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class DiagramSwitchHeader extends StatefulWidget {
  const DiagramSwitchHeader({super.key});

  @override
  State<DiagramSwitchHeader> createState() => _DiagramSwitchHeaderState();
}

class _DiagramSwitchHeaderState extends State<DiagramSwitchHeader> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
    );
  }
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
    return ListTile(
      title: Text(diagram.name),
      onTap: () => onChanged(index),
    );
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
              AppBar(
                // backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text('${step.runtimeType}'),
              ),
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
