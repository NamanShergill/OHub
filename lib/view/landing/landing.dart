// import 'package:animations/animations.dart';
// import 'package:auto_route/annotations.dart';
// import 'package:diohub/adapters/deep_linking_handler.dart';
// import 'package:diohub/common/misc/scaffold_body.dart';
// import 'package:diohub/providers/users/current_user_provider.dart';
// import 'package:diohub/view/home/home.dart';
// import 'package:diohub/view/notifications/notifications.dart';
// import 'package:diohub/view/search/search.dart';
// import 'package:diohub/view/settings/settings.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// @RoutePage()
// class LandingScreen extends StatefulWidget {
//   const LandingScreen({this.deepLinkData, super.key});
//
//   final PathData? deepLinkData;
//
//   @override
//   LandingScreenState createState() => LandingScreenState();
// }
//
// class LandingScreenState extends State<LandingScreen>
//     with SingleTickerProviderStateMixin {
//   // late TabController _controller;
//   @override
//   void initState() {
//     currentIndex = getPath(widget.deepLinkData?.path);
//     // _controller = TabController(
//     //   length: 5,
//     //   vsync: this,
//     //   initialIndex: getPath(widget.deepLinkData?.path),
//     // );
//
//     ColorScheme.fromImageProvider(
//       brightness: Brightness.dark,
//       provider: NetworkImage(
//           context.read<CurrentUserProvider>().data.avatarUrl.toString()!),
//     ).then((value) {
//       print(value);
//     });
//     super.initState();
//   }
//
//   late int currentIndex;
//
//   int getPath(final String? path) {
//     if (path == 'search') {
//       return 1;
//     } else if (path == 'notifications') {
//       return 2;
//     } else {
//       return 0;
//     }
//   }
//
//   @override
//   Widget build(final BuildContext context) => SafeArea(
//         child:
//             // ThemeFromImage(
//             //   builder: (context, buildThemePZero) =>
//             Scaffold(
//           body: ScaffoldBody(
//             child: PageTransitionSwitcher(
//               transitionBuilder: (
//                 final Widget child,
//                 final Animation<double> primaryAnimation,
//                 final Animation<double> secondaryAnimation,
//               ) =>
//                   FadeThroughTransition(
//                 animation: primaryAnimation,
//                 secondaryAnimation: secondaryAnimation,
//                 child: child,
//               ),
//               child: switch (currentIndex) {
//                 0 => HomeScreen(
//                     deepLinkData: widget.deepLinkData,
//                     // buildThemePZero: buildThemePZero,
//                     tabNavigators: (
//                       toProfile: () {
//                         setState(() {
//                           currentIndex = 3;
//                         });
//                       },
//                       toSearch: () {
//                         setState(() {
//                           currentIndex = 1;
//                         });
//                       }
//                     ),
//                   ),
//                 1 => const SearchScreen(),
//                 2 => const NotificationsScreen(),
//                 // 3 => const CurrentUserProfileScreen(),
//                 4 => const SettingsScreen(),
//                 _ => throw UnimplementedError(),
//               },
//             ),
//           ),
//         ),
//         /
//       );
// }
