import 'package:auto_route/annotations.dart';
import 'package:dio_hub/common/misc/loading_indicator.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PlaceHolderScreen extends StatelessWidget {
  const PlaceHolderScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LoadingIndicator(),
    );
  }
}
