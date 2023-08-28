import 'package:dio_hub/app/Dio/dio.dart';
import 'package:dio_hub/app/settings/palette.dart';
import 'package:dio_hub/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:dio_hub/common/const/app_info.dart';
import 'package:dio_hub/common/const/version_info.dart';
import 'package:dio_hub/common/misc/app_scroll_view.dart';
import 'package:dio_hub/common/misc/button.dart';
import 'package:dio_hub/common/misc/info_card.dart';
import 'package:dio_hub/common/misc/profile_card.dart';
import 'package:dio_hub/common/misc/repository_card.dart';
import 'package:dio_hub/utils/http_to_api.dart';
import 'package:dio_hub/utils/link_handler.dart';
import 'package:dio_hub/view/settings/widgets/color_setting_card.dart';
import 'package:dio_hub/view/settings/widgets/language_setting_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return AppScrollView(
      scrollViewAppBar: ScrollViewAppBar(
        expandedHeight: 180,
        collapsedHeight: 60,
        appBarWidget: AppInfoWidget(
          axis: Axis.horizontal,
          logoSize: 30,
          nameSize: Theme.of(context).textTheme.titleLarge!.fontSize!,
        ),
        flexibleBackgroundWidget: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppInfoWidget(
              axis: Axis.horizontal,
              logoSize: 45,
              nameSize: 30,
            ),
            VersionInfoWidget(),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 8),
            //   child: Text(
            //     'App Settings',
            //     style: Theme.of(context).textTheme.headlineSmall,
            //   ),
            // ),
            // Row(
            //   children: const [
            //     VersionInfoWidget(),
            //   ],
            // ),
          ],
        ),
        bottomPadding: 60,
        tabController: controller,
        tabs: const [
          'General',
          'About',
        ],
      ),
      tabController: controller,
      childrenColor:
          Provider.of<PaletteSettings>(context).currentSetting.primary,
      tabViews: const [
        _GeneralSettings(),
        _About(),
      ],
    );
//     return NestedScrollView(
//       controller: scrollController,
//       headerSliverBuilder: (context, _) {
//         return [
//           SliverOverlapAbsorber(
//             handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
//             sliver: SliverSafeArea(
//               sliver: SliverAppBar(
//                 expandedHeight: 120,
//                 collapsedHeight: 100,
//                 pinned: true,
//                 elevation: 2,
//                 backgroundColor: Provider.of<PaletteSettings>(context).currentSetting.background,
//                 flexibleSpace: GestureDetector(
//                   child: const CollapsibleAppBar(
//                     minHeight: 100,
//                     maxHeight: 120,
//                     expandedParentPadding: 0,
//                     title: 'App Settings',
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ];
//       },
//       body: Builder(
//         builder: (context) {
//           NestedScrollView.sliverOverlapAbsorberHandleFor(context);
//           return DefaultTabController(
//             length: 2,
//             initialIndex: 0,
//             child: Column(
//               // crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16),
//                   child: AppTabBar(tabs: [
//                     AppTab(
//                       title: 'General',
//                     ),
//                     AppTab(
//                       title: 'About',
//                     ),
//                   ]),
//                 ),
//                 Expanded(
//                   child: TabBarView(children: [
// ,
//                     Container(),
//                   ]),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
  }
}

class _GeneralSettings extends StatelessWidget {
  const _GeneralSettings();

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 8,
            ),
            const FontSettingCard(),
            const ColorSettingCard(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: StringButton(
                color: Provider.of<PaletteSettings>(context)
                    .currentSetting
                    .secondary,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (final context) => AlertDialog(
                      title: Text(
                        'Log Out?',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      actions: [
                        MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        MaterialButton(
                          onPressed: () {
                            BlocProvider.of<AuthenticationBloc>(context)
                                .add(LogOut());
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Confirm',
                          ),
                        ),
                      ],
                    ),
                  );
                },
                title: 'Log Out',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: StringButton(
                color: Provider.of<PaletteSettings>(context)
                    .currentSetting
                    .secondary,
                onTap: BaseAPIHandler.clearCache,
                title: 'Clear Cache',
              ),
            ),
          ],
        ),
      );
}

class _About extends StatelessWidget {
  const _About();

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
        child: Column(
          children: [
            InfoCard(
              mode: InfoCardMode.expanded,
              title: 'Repository',
              child: RepoCardLoading(
                toRepoAPIResource('https://github.com/NamanShergill/diohub'),
                'diohub',
              ),
            ),
            const InfoCard(
              title: 'Maintained By',
              mode: InfoCardMode.expanded,
              child: ProfileCardLoading(
                'NamanShergill',
                compact: true,
              ),
            ),
            InfoCard(
              title: 'Bugs or Suggestions?',
              mode: InfoCardMode.expanded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Let me know at'),
                  ),
                  Material(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Provider.of<PaletteSettings>(context)
                        .currentSetting
                        .primary,
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        linkHandler(
                          context,
                          'https://github.com/NamanShergill/diohub/issues',
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'https://github.com/NamanShergill/diohub/issues',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8),
              child: StringButton(
                color: Provider.of<PaletteSettings>(context)
                    .currentSetting
                    .secondary,
                onTap: () {
                  PackageInfo.fromPlatform().then((final value) {
                    showLicensePage(
                      context: context,
                      applicationIcon: const AppLogoWidget(
                        size: 50,
                      ),
                      applicationName: 'DioHub',
                      applicationVersion: value.version,
                    );
                  });
                  // AutoRouter.of(context).push(const DependenciesScreenRoute());
                },
                title: 'Licenses',
              ),
            ),
          ],
        ),
      );
}
