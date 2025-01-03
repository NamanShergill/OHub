import 'package:auto_route/annotations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:diohub/adapters/deep_linking_handler.dart';
import 'package:diohub/common/animations/size_expanded_widget.dart';
import 'package:diohub/common/events/events.dart';
import 'package:diohub/common/misc/button.dart';
import 'package:diohub/common/misc/collapsible_app_bar.dart';
import 'package:diohub/common/misc/ink_pot.dart';
import 'package:diohub/common/misc/profile_banner.dart';
import 'package:diohub/common/misc/shimmer_widget.dart';
import 'package:diohub/common/wrappers/dynamic_tabs_parent.dart';
import 'package:diohub/common/wrappers/infinite_scroll_wrapper.dart';
import 'package:diohub/graphql/queries/viewer/__generated__/viewer.query.data.gql.dart';
import 'package:diohub/providers/base_provider.dart';
import 'package:diohub/providers/users/current_user_provider.dart';
import 'package:diohub/services/users/user_info_service.dart';
import 'package:diohub/utils/utils.dart';
import 'package:diohub/view/home/widgets/issues_tab.dart';
import 'package:diohub/view/home/widgets/pulls_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dynamic_tabs/flutter_dynamic_tabs.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.deepLinkData,
    this.buildThemePZero,
  });

  final dynamic buildThemePZero;
  final PathData? deepLinkData;

  // final TabController parentTabController;
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  // late TabController _tabController;

  late final DynamicTabsController tabsController = DynamicTabsController(
    vsync: this,
    tabs: _buildTabs(),
  );

  List<DynamicTab> _buildTabs() => <DynamicTab>[
        DynamicTab(
          identifier: 'Events',
          isDismissible: false,
          tabViewBuilder: (final BuildContext context) => const Events(
            isTimeline: false,
          ),
        ),
        DynamicTab(
          identifier: 'Issues',
          tabViewBuilder: (final BuildContext context) => IssuesTab(
            deepLinkData: widget.deepLinkData?.components.first == 'issues'
                ? widget.deepLinkData
                : null,
          ),
        ),
        DynamicTab(
          identifier: 'Pulls',
          tab: TabBarItem(label: 'Pull Requests'),
          tabViewBuilder: (final BuildContext context) => PullsTab(
            deepLinkData: widget.deepLinkData?.components.first == 'pulls'
                ? widget.deepLinkData
                : null,
          ),
        ),
        DynamicTab(
          identifier: 'orgs',
          tab: TabBarItem(label: 'Organizations'),
          tabViewBuilder: (final BuildContext context) => InfiniteScrollWrapper<
              GgetViewerOrgsData_viewer_organizations_edges?>(
            future: (
              final ScrollWrapperFutureArguments<
                      GgetViewerOrgsData_viewer_organizations_edges?>
                  data,
            ) async =>
                UserInfoService.getViewerOrgs(
              refresh: data.refresh,
              after: data.lastItem?.cursor,
            ),
            separatorBuilder: (final BuildContext context, final int index) =>
                const Divider(
              height: 8,
            ),
            listEndIndicator: false,
            // divider: false,
            builder: (
              final BuildContext context,
              final ScrollWrapperBuilderData<
                      GgetViewerOrgsData_viewer_organizations_edges?>
                  data,
            ) =>
                Row(
              children: <Widget>[
                Expanded(
                  child: ProfileTile.login(
                    avatarUrl: data.item?.node?.avatarUrl.toString(),
                    userLogin: data.item?.node?.login,
                    padding: const EdgeInsets.all(16),
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];

  @override
  void initState() {
    // _tabController = TabController(vsync: this, length: 5, initialIndex: 0);
    // if (widget.deepLinkData?.components.first == 'issues') {
    //   _tabController.index = 1;
    // } else if (widget.deepLinkData?.components.first == 'pulls') {
    //   _tabController.index = 2;
    // }
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    super.build(context);
    return SafeArea(
      child: DynamicTabsParent(
        controller: tabsController,
        builder: (final BuildContext context, final PreferredSizeWidget tabBar,
                final Widget tabView) =>
            DynamicScroll(
          collapsedWidget: buildCollapsedAppBar(context),
          bottom: SizeExpandedSection(
            expand: tabsController.activeLength > 1,
            child: tabBar,
          ),
          expandedWidget: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              children: <Widget>[
                buildProfileCard(context),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButtonTheme(
                  data: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      iconSize: 16,
                      textStyle: context.textTheme.labelMedium,
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: <Widget>[
                        AppButton.icon(
                          onPressed: () {
                            tabsController.openTab('Issues');
                          },
                          icon: const Icon(
                            Octicons.issue_opened,
                            // color: Colors.green,
                          ),
                          child: Text(
                            '${context.viewer.issues.totalCount} Issues',
                          ),
                        ),
                        AppButton.icon(
                          onPressed: () {
                            tabsController.openTab('Pulls');
                          },
                          icon: const Icon(
                            Octicons.git_pull_request,
                            // color: Colors.green,
                          ),
                          child: Text(
                            '${context.viewer.pullRequests.totalCount} Pull Requests',
                          ),
                        ),
                        AppButton.icon(
                          onPressed: () {
                            tabsController.openTab('orgs');
                          },
                          icon: const Icon(
                            Octicons.organization,
                          ),
                          child: Text(
                            '${context.viewer.organizations.totalCount} Organizations',
                          ),
                        ),
                        AppButton.icon(
                          onPressed: () {
                            // tabsController.openTab('repos');
                          },
                          icon: const Icon(
                            Octicons.repo,
                          ),
                          child: Text(
                            '${context.viewer.repositories.totalCount} Repos',
                          ),
                        ),
                        AppButton.icon(
                          onPressed: () {
                            // tabsController.openTab('repos');
                          },
                          icon: const Icon(
                            Icons.settings_rounded,
                          ),
                          child: const Text(
                            'App Settings',
                          ),
                        ),
                      ]
                          .map(
                            (final Widget e) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: e,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: tabView,
        ),
      ),
    );
  }

  Row buildProfileCard(final BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Row(
            children: <Widget>[
              ProfileTile.avatar(
                // fullName: context.provider<CurrentUserProvider>().data.name,
                avatarUrl: context
                    .provider<CurrentUserProvider>()
                    .data
                    .avatarUrl
                    .toString(),
                userLogin: context.provider<CurrentUserProvider>().data.login,
                padding: const EdgeInsets.all(16),
                size: 32,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    context.provider<CurrentUserProvider>().data.name!,
                    style: context.textTheme.titleMedium?.asBold(),
                  ),
                  Text(
                    context.provider<CurrentUserProvider>().data.login,
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: () {},
                child: const Icon(
                  Icons.notifications_rounded,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Icon(
                  Icons.search_rounded,
                ),
              ),
            ],
          ),
        ],
      );

  Row buildCollapsedAppBar(final BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ClipOval(
            child: InkPot(
              onTap: () {
                // widget.tabNavigators.toProfile();
              },
              child: CachedNetworkImage(
                height: 32,
                imageUrl: context.viewer.avatarUrl.toString(),
                placeholder: (final BuildContext context, final _) =>
                    ShimmerWidget(
                  child: Container(
                    color: context.colorScheme.surface,
                  ),
                ),
                // )
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            context.provider<CurrentUserProvider>().data.login,
            style: context.textTheme.bodyMedium?.asBold(),
          ),
        ],
      );
}
