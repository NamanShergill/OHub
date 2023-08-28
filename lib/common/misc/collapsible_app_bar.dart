import 'package:dio_hub/common/animations/size_expanded_widget.dart';
import 'package:flutter/material.dart';

class CollapsibleAppBar extends StatelessWidget {
  const CollapsibleAppBar({
    this.title,
    this.child,
    this.childHeight = 60,
    this.minHeight,
    this.maxHeight,
    this.expandedParentPadding = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
    this.childCollapseValue = 0.75,
    this.trailing,
    super.key,
  });
  final double? maxHeight;
  final double? minHeight;
  final String? title;
  final Widget? trailing;
  final double childCollapseValue;
  final Widget? child;
  final double expandedParentPadding;
  final EdgeInsets padding;
  final double childHeight;

  double _calculateExpandRatio(final BoxConstraints constraints) {
    var expandRatio =
        (constraints.maxHeight - minHeight!) / (maxHeight! - minHeight!);
    if (expandRatio > 1.0) {
      expandRatio = 1.0;
    }
    if (expandRatio < 0.0) {
      expandRatio = 0.0;
    }
    return expandRatio;
  }

  double _calculateAbsExpandRatio(final BoxConstraints constraints) {
    final expandRatio =
        (constraints.maxHeight - minHeight!) / (maxHeight! - minHeight!);
    return expandRatio;
  }

  @override
  Widget build(final BuildContext context) => LayoutBuilder(
        builder: (final context, final constraints) {
          final expandRatio = _calculateExpandRatio(constraints);
          final animation = AlwaysStoppedAnimation(expandRatio);
          final absRatio = _calculateAbsExpandRatio(constraints);

          return Padding(
            padding: padding,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: AlignmentTween(
                    begin: child != null
                        ? Alignment.topLeft
                        : Alignment.bottomLeft,
                    end: child != null
                        ? Alignment.centerLeft
                        : Alignment.bottomLeft,
                  ).evaluate(animation),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: child != null ? 30 : 0),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            Tween<double>(begin: 0, end: expandedParentPadding)
                                .evaluate(animation),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title!,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: Tween<double>(begin: 26, end: 36)
                                      .evaluate(animation),
                                ),
                          ),
                          SizedBox(
                            height: Tween<double>(begin: 50, end: 60)
                                .evaluate(animation),
                            width: Tween<double>(begin: 50, end: 60)
                                .evaluate(animation),
                            child: trailing,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizeExpandedSection(
                        expand: absRatio > childCollapseValue,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 35),
                          child: child,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
}
