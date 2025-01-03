import 'package:diohub/common/animations/size_expanded_widget.dart';
import 'package:diohub/common/bottom_sheet/bottom_sheets.dart';
import 'package:diohub/common/misc/button.dart';
import 'package:diohub/common/misc/nested_scroll.dart';
import 'package:diohub/common/wrappers/infinite_scroll_wrapper.dart';
import 'package:diohub/models/events/notifications_model.dart';
import 'package:diohub/services/activity/notifications_service.dart';
import 'package:diohub/utils/type_cast.dart';
import 'package:diohub/view/notifications/widgets/filter_sheet.dart';
import 'package:diohub/view/notifications/widgets/notification_cards/issue_notification_card.dart';
import 'package:diohub/view/notifications/widgets/notification_cards/pull_request_notification_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen>
    with AutomaticKeepAliveClientMixin {
  /// Filters to be supplied to the API.
  Map<String, dynamic> apiFilters = <String, dynamic>{'all': true};

  /// Filters to be applied client side.
  Map<String, dynamic> clientFilters = <String, dynamic>{
    'show_only': <dynamic>[],
  };

  /// Is the action button pane expanded.
  bool expanded = false;

  /// Controller for the infinite pagination wrapper.
  final InfiniteScrollWrapperController _controller =
      InfiniteScrollWrapperController();

  /// 'Mark all as read" button status.
  bool loadingButton = false;

  /// Function to check if a specific notification fits the user filter or not.
  bool? checkFilter(final NotificationModel notification) {
    bool? allowed = true;
    if (clientFilters['show_only'].isNotEmpty) {
      allowed = clientFilters['show_only'].contains(notification.reason);
    }
    return allowed;
  }

  /// Show bottom sheet to apply filters.
  Future<void> showFilterSheet() async {
    await showScrollableBottomSheet(
      context,
      scrollableBodyBuilder: (
        final BuildContext context,
        final StateSetter setState,
        final ScrollController scrollController,
      ) =>
          FilterSheet(
        apiFilters: apiFilters,
        controller: scrollController,
        clientFilters: clientFilters,
        onFiltersChanged: (
          final TypeMap updatedAPIFilters,
          final TypeMap updatedClientFilters,
        ) {
          apiFilters = updatedAPIFilters;
          clientFilters = updatedClientFilters;
          _controller.refresh();
        },
      ),
      headerBuilder: (final BuildContext context, final StateSetter setState) =>
          const BottomSheetHeaderText(
        headerText: 'Filter Notifications',
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(final BuildContext context) {
    super.build(context);
    return NestedScroll(
      header: (final (BuildContext, {bool isInnerBoxScrolled}) data) =>
          <Widget>[
        SliverAppBar(
          expandedHeight: 150,
          collapsedHeight: 100,
          pinned: true,
          elevation: 2,
          // backgroundColor:
          //     Provider.of<PaletteSettings>(context).currentSetting.primary,
          flexibleSpace: GestureDetector(
            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },
            // child: CollapsibleScroller(
            //   minHeight: 100,
            //   maxHeight: 150,
            //   expandedParentPadding: 0,
            //   title: 'Inbox',
            //   trailing: IconButton(
            //     icon: const Icon(Icons.sort),
            //     onPressed: () {
            //       setState(() {
            //         expanded = !expanded;
            //       });
            //     },
            //   ),
            // ),
          ),
        ),
      ],
      body: Builder(
        builder: (final BuildContext context) {
          NestedScrollView.sliverOverlapAbsorberHandleFor(context);
          return Column(
            children: <Widget>[
              SizeExpandedSection(
                expand: expanded,
                child: Column(
                  children: <Widget>[
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Button(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        onTap: () async {
                          setState(() {
                            loadingButton = true;
                          });
                          await NotificationsService.markAllAsRead();
                          setState(() {
                            loadingButton = false;
                          });
                          _controller.refresh();
                        },
                        enabled: !loadingButton,
                        // color: Provider.of<PaletteSettings>(context)
                        //     .currentSetting
                        //     .secondary,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Mark all as read',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const Icon(
                              MdiIcons.checkCircle,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Button(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        onTap: showFilterSheet,
                        // color: Provider.of<PaletteSettings>(context)
                        //     .currentSetting
                        //     .secondary,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Filter Inbox',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const Icon(
                              MdiIcons.filter,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ),
              Expanded(
                child: InfiniteScrollWrapper<NotificationModel>(
                  controller: _controller,
                  separatorBuilder:
                      (final BuildContext context, final int index) =>
                          const Divider(
                    height: 0,
                  ),
                  future: (
                    data,
                  ) async =>
                      NotificationsService.getNotifications(
                    page: data.pageNumber,
                    perPage: data.pageSize,
                    filters: apiFilters,
                  ),
                  filterFn: (final List<NotificationModel> list) {
                    final List<NotificationModel> filtered =
                        <NotificationModel>[];
                    for (final NotificationModel element in list) {
                      if (checkFilter(element)!) {
                        filtered.add(element);
                      }
                    }
                    return filtered;
                  },
                  builder: (
                    final BuildContext context,
                    final data,
                  ) {
                    if (data.item.subject!.type == SubjectType.ISSUE) {
                      return IssueNotificationCard(
                        data.item,
                        refresh: data.refresh,
                      );
                    } else if (data.item.subject!.type ==
                        SubjectType.PULL_REQUEST) {
                      return PullRequestNotificationCard(
                        data.item,
                        refresh: data.refresh,
                      );
                    }
                    return Container();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// class UnauthenticatedNotificationsReplacement extends StatelessWidget {
//   const UnauthenticatedNotificationsReplacement({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         NestedScrollView(
//             headerSliverBuilder: (context, _) {
//               return [
//                 SliverOverlapAbsorber(
//                   handle:
//                       NestedScrollView.sliverOverlapAbsorberHandleFor(context),
//                   sliver: SliverAppBar(
//                     expandedHeight: 150,
//                     collapsedHeight: 100,
//                     pinned: true,
//                     elevation: 2,
//                     backgroundColor: Provider.of<PaletteSettings>(context).currentSetting.background,
//                     flexibleSpace: GestureDetector(
//                       child: const CollapsibleAppBar(
//                         minHeight: 100,
//                         maxHeight: 150,
//                         expandedParentPadding: 0,
//                         title: 'Inbox',
//                         trailing: IconButton(
//                           icon: Icon(
//                             Icons.sort,
//                             color: white,
//                           ),
//                           onPressed: null,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ];
//             },
//             body: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: const [
//                 Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: LoginPromptBox(),
//                 ),
//               ],
//             )),
//       ],
//     );
//   }
// }
