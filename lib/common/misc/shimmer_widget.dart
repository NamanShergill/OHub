import 'package:dio_hub/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  const ShimmerWidget({
    this.child,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
    super.key,
  });
  final Widget? child;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  @override
  Widget build(final BuildContext context) => ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(0),
        child: Shimmer.fromColors(
          baseColor: baseColor ?? context.colorScheme.surfaceVariant.asHint(),
          highlightColor: highlightColor ?? context.colorScheme.surfaceVariant,
          child: child ?? Container(),
        ),
      );
}
