import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

class NestedScroll extends StatelessWidget {
  const NestedScroll({
    required this.header,
    required this.body,
    super.key,
  });

  final List<Widget> Function(
    (
      BuildContext context, {
      bool isInnerBoxScrolled,
    }) data,
  ) header;
  final Widget body;

  @override
  Widget build(final BuildContext context) => NestedScrollView(
        headerSliverBuilder: (final BuildContext context, final bool value) =>
            <Widget>[
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverSafeArea(
              // bottom: false,
              sliver: MultiSliver(
                children: header(
                  (
                    context,
                    isInnerBoxScrolled: value,
                  ),
                ),
              ),
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
