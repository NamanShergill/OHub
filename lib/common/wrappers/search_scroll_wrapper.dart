import 'package:dio_hub/app/settings/palette.dart';
import 'package:dio_hub/common/issues/issue_list_card.dart';
import 'package:dio_hub/common/misc/profile_card.dart';
import 'package:dio_hub/common/misc/repository_card.dart';
import 'package:dio_hub/common/search_overlay/filters.dart';
import 'package:dio_hub/common/search_overlay/search_bar.dart';
import 'package:dio_hub/common/search_overlay/search_overlay.dart';
import 'package:dio_hub/common/wrappers/infinite_scroll_wrapper.dart';
import 'package:dio_hub/models/issues/issue_model.dart';
import 'package:dio_hub/models/repositories/repository_model.dart' hide Type;
import 'package:dio_hub/models/users/user_info_model.dart';
import 'package:dio_hub/services/search/search_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';
import 'package:provider/provider.dart';

typedef SearchScrollWrapperFuture<T> = Future Function(int pageNumber,
    int pageSize, bool refresh, T? lastItem, String? sort, bool? isAscending);

typedef WrapperReplacementBuilder = Widget Function(SearchData searchData,
    Widget Function(BuildContext, Function) header, Widget child);

class SearchScrollWrapper extends StatefulWidget {
  SearchScrollWrapper(this.searchData,
      {this.searchBarMessage,
      this.quickFilters,
      this.replacementBuilder,
      this.quickOptions,
      this.nestedScrollViewController,
      this.isNestedScrollViewChild = true,
      EdgeInsets? searchBarPadding,
      this.onChanged,
      this.searchBarColor,
      this.padding = const EdgeInsets.symmetric(horizontal: 8),
      this.searchHeroTag,
      this.filterFn,
      this.showRepoNameOnIssues = true,
      Key? key})
      : _searchBarPadding = searchBarPadding ?? padding.copyWith(top: 8),
        super(key: key);

  /// Search Data this search wrapper would be attached to.
  final SearchData searchData;

  /// Filter function for the search results.
  final FilterFn? filterFn;

  /// Message to show on the search bar.
  final String? searchBarMessage;

  /// Hero tag of the search bar.
  final String? searchHeroTag;

  /// Padding of wrapper.
  final EdgeInsets padding;
  final EdgeInsets _searchBarPadding;

  /// Background color of the search bar.
  final Color? searchBarColor;

  /// Quick filters to be shown in the search bar in a dropdown.
  final Map<String, String>? quickFilters;

  /// Quick options to be shown in the search bar as a checkbox.
  final Map<String, String>? quickOptions;

  /// Scroll controller of the infinite list.
  final ScrollController? nestedScrollViewController;

  /// Is the child of a nested scroll view.
  final bool isNestedScrollViewChild;

  /// Replacement builder if search data is empty.
  final WrapperReplacementBuilder? replacementBuilder;

  /// Callback for when search data is changed.
  final ValueChanged<SearchData>? onChanged;

  final bool showRepoNameOnIssues;
  @override
  _SearchScrollWrapperState createState() => _SearchScrollWrapperState();
}

class _SearchScrollWrapperState extends State<SearchScrollWrapper> {
  late SearchData searchData;

  @override
  void initState() {
    searchData = widget.searchData;
    super.initState();
  }

  bool searchBarHidden = false;
  Size? size;
  InfiniteScrollWrapperController controller =
      InfiniteScrollWrapperController();

  @override
  Widget build(BuildContext context) {
    Widget header(context, function) {
      return Padding(
        padding: function != null ? EdgeInsets.zero : widget._searchBarPadding,
        child: SearchBar(
          heroTag: widget.searchHeroTag != null
              ? widget.searchHeroTag! + (function != null).toString()
              : null,
          quickFilters: widget.quickFilters,
          quickOptions: widget.quickOptions,
          searchData: searchData,
          isPinned: function != null,
          trailing: function != null
              ? IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up_rounded),
                  onPressed: () {
                    function();
                  })
              : null,
          prompt: widget.searchBarMessage,
          backgroundColor: widget.searchBarColor ??
              Provider.of<PaletteSettings>(context).currentSetting.primary,
          onSubmit: (data) {
            setState(() {
              searchData = data;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(data);
            }
            controller.refresh();
          },
        ),
      );
    }

    final Widget child = Container(
      color: Provider.of<PaletteSettings>(context).currentSetting.secondary,
      child: Builder(
        builder: (context) {
          if (searchData.searchFilters!.searchType == SearchType.repositories) {
            return _InfiniteWrapper<RepositoryModel>(
              controller: controller,
              searchData: searchData,
              filterFn: widget.filterFn,
              isNestedScrollViewChild: widget.isNestedScrollViewChild,
              nestedScrollViewController: widget.nestedScrollViewController,
              searchFuture: (pageNumber, pageSize, refresh, _) {
                return SearchService.searchRepos(searchData.toQuery,
                    perPage: pageSize,
                    page: pageNumber,
                    sort: searchData.getSort,
                    ascending: searchData.isSortAsc,
                    refresh: refresh);
              },
              header: (context) => header(context, null),
              pinnedHeader: searchData.isActive ? header : null,
              builder: (context, item, index, refresh) {
                return Padding(
                  padding: widget.padding,
                  child: RepositoryCard(
                    item,
                    padding: EdgeInsets.zero,
                  ),
                );
              },
            );
          } else if (searchData.searchFilters!.searchType ==
              SearchType.issuesPulls) {
            return _InfiniteWrapper<IssueModel>(
              filterFn: widget.filterFn,
              controller: controller,
              searchData: searchData,
              nestedScrollViewController: widget.nestedScrollViewController,
              searchFuture: (pageNumber, pageSize, refresh, _) {
                return SearchService.searchIssues(searchData.toQuery,
                    perPage: pageSize,
                    page: pageNumber,
                    sort: searchData.getSort,
                    ascending: searchData.isSortAsc,
                    refresh: refresh);
              },
              isNestedScrollViewChild: widget.isNestedScrollViewChild,
              header: (context) => header(context, null),
              pinnedHeader: searchData.isActive ? header : null,
              builder: (context, item, index, refresh) {
                return Padding(
                  padding: widget.padding,
                  child: IssueListCard(
                    item,
                    padding: EdgeInsets.zero,
                    showRepoName: widget.showRepoNameOnIssues,
                  ),
                );
              },
            );
          } else if (searchData.searchFilters!.searchType == SearchType.users) {
            return _InfiniteWrapper<UserInfoModel>(
              filterFn: widget.filterFn,
              controller: controller,
              searchData: searchData,
              nestedScrollViewController: widget.nestedScrollViewController,
              header: (context) => header(context, null),
              pinnedHeader: searchData.isActive ? header : null,
              searchFuture: (pageNumber, pageSize, refresh, _) {
                return SearchService.searchUsers(searchData.toQuery,
                    perPage: pageSize,
                    page: pageNumber,
                    sort: searchData.getSort,
                    ascending: searchData.isSortAsc,
                    refresh: refresh);
              },
              isNestedScrollViewChild: widget.isNestedScrollViewChild,
              builder: (context, item, index, refresh) {
                return Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: widget.padding,
                        child: ProfileCard(
                          item,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
          return Container();
        },
      ),
    );
    if (widget.replacementBuilder != null) {
      return widget.replacementBuilder!(searchData, header, child);
    }
    return child;
  }
}

class _InfiniteWrapper<T> extends StatelessWidget {
  const _InfiniteWrapper(
      {required this.builder,
      required this.header,
      this.isNestedScrollViewChild = true,
      required this.controller,
      this.nestedScrollViewController,
      this.filterFn,
      this.pinnedHeader,
      required this.searchFuture,
      required this.searchData,
      Key? key})
      : super(key: key);
  final InfiniteScrollWrapperController controller;
  final WidgetBuilder header;
  final ScrollWrapperFuture searchFuture;
  final ScrollWrapperBuilder builder;
  final SearchData searchData;
  final FilterFn? filterFn;
  final bool isNestedScrollViewChild;
  final ScrollController? nestedScrollViewController;
  final ReplacementBuilder? pinnedHeader;

  @override
  Widget build(BuildContext context) {
    return InfiniteScrollWrapper<T>(
      pageSize: 20,
      controller: controller,
      header: header,
      filterFn: filterFn,
      scrollController: nestedScrollViewController,
      future: searchFuture,
      paginationKey: ValueKey(searchData.toQuery +
          searchData.isActive.toString() +
          searchData.sort),
      separatorBuilder: (context, index) => const SizedBox(
        height: 4,
      ),
      firstDivider: false,
      pinnedHeader: pinnedHeader,
      shrinkWrap: true,
      isNestedScrollViewChild: isNestedScrollViewChild,
      topSpacing: 0,
      builder: builder,
    );
  }
}
