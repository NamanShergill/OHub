import 'package:diohub/utils/utils.dart';
import 'package:flutter/material.dart';

class ScrollDynamicElevation extends StatefulWidget {
  const ScrollDynamicElevation({
    required this.child,
    super.key,
  });

  final Widget child;
  @override
  State<ScrollDynamicElevation> createState() => _ScrollDynamicElevationState();
}

class _ScrollDynamicElevationState extends State<ScrollDynamicElevation> {
  ScrollNotificationObserverState? _scrollNotificationObserver;

  bool _scrolledUnder = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollNotificationObserver?.removeListener(_handleScrollNotification);
    _scrollNotificationObserver = ScrollNotificationObserver.maybeOf(context);

    _scrollNotificationObserver?.addListener(_handleScrollNotification);
  }

  @override
  void dispose() {
    if (_scrollNotificationObserver != null) {
      _scrollNotificationObserver!.removeListener(_handleScrollNotification);
      _scrollNotificationObserver = null;
    }
    super.dispose();
  }

  void _handleScrollNotification(final ScrollNotification notification) {
    if (notification is ScrollUpdateNotification &&
        defaultScrollNotificationPredicate(notification)) {
      final bool oldScrolledUnder = _scrolledUnder;
      final ScrollMetrics metrics = notification.metrics;
      switch (metrics.axisDirection) {
        case AxisDirection.up:
          // Scroll view is reversed
          _scrolledUnder = metrics.extentAfter > 0;
        case AxisDirection.down:
          _scrolledUnder = metrics.extentBefore > 0;
        case AxisDirection.right:
        case AxisDirection.left:
          // Scrolled under is only supported in the vertical axis, and should
          // not be altered based on horizontal notifications of the same
          // predicate since it could be a 2D scroller.
          break;
      }

      if (_scrolledUnder != oldScrolledUnder) {
        setState(() {
          // React to a change in MaterialState.scrolledUnder
        });
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    final FlexibleSpaceBarSettings? settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

    final Set<MaterialState> states = <MaterialState>{
      if (settings?.isScrolledUnder ?? _scrolledUnder)
        MaterialState.scrolledUnder,
    };
    return ColoredBox(
      color: states.contains(MaterialState.scrolledUnder)
          ? ElevationOverlay.applySurfaceTint(
              context.colorScheme.background,
              context.colorScheme.surfaceTint,
              3,
            )
          : context.colorScheme.background,
      // duration: Duration(milliseconds: 100),
      child: widget.child,
    );
  }
}

bool defaultScrollNotificationPredicate(
  final ScrollNotification notification,
) =>
    notification.depth == 0;
