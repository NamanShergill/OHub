import 'package:diohub/common/misc/scroll_dynamic_elevation.dart';
import 'package:diohub/utils/utils.dart';
import 'package:dynamic_sliver_app_bar/dynamic_sliver_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

class DynamicScroll extends StatelessWidget {
  const DynamicScroll({
    required this.expandedWidget,
    required this.collapsedWidget,
    required this.body,
    this.bottom,
    super.key,
  });

  final Widget collapsedWidget;
  final Widget expandedWidget;
  final Widget? bottom;
  final Widget body;

  @override
  Widget build(final BuildContext context) => NestedScrollView(
        headerSliverBuilder: (final BuildContext context, final bool value) =>
            <Widget>[
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverSafeArea(
              // bottom: false,
              sliver: MultiSliver(children: <Widget>[
                DynamicSliverAppBar(
                  // backgroundColor: Colors.transparent,
                  // elevation: 0,
                  toolbarHeight: 64,
                  surfaceTintColor: ElevationOverlay.applySurfaceTint(
                    context.colorScheme.background,
                    context.colorScheme.surfaceTint,
                    3,
                  ),
                  flexibleSpace: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainer,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(child: expandedWidget),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: context.colorScheme.onInverseSurface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // height: 400,
                  ),
                  title: collapsedWidget,
                  // bottom: bottom,
                  // snap: true,
                  pinned: true,
                  // floating: true,
                ),
                if (bottom != null)
                  SliverPinnedHeader(
                    child: ScrollDynamicElevation(
                      child: bottom!,
                    ),
                  )
              ]),
            ),
          ),
        ],
        body: Builder(
          builder: (final BuildContext context) {
            NestedScrollView.sliverOverlapAbsorberHandleFor(context);

            return body;
          },
        ),
      );
}
